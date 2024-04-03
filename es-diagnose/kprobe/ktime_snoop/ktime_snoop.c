#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include <linux/slab.h>
#include <linux/kprobes.h>
#include <linux/string.h>
#include <linux/kallsyms.h>

#include <linux/kmod.h>
#include <linux/sched.h>

#define MAX_SIZE 8192
#define FILE_NAME_LEN 32

#define FUNC_NAME_LEN 128
#define OFFSET_LEN 8
#define PROC_COMM_SIZE 32
#define DURATION_THRESHOLD_LEN 16
#define RECORD_LEN (FUNC_NAME_LEN + OFFSET_LEN * 2 +	\
					PROC_COMM_SIZE + DURATION_THRESHOLD_LEN)

#define MAX_RECORD (MAX_SIZE / RECORD_LEN)
static char *argv[] = { "/usr/bin/save_dmesg", NULL };
static char *envp[] = { "HOME=/", "PATH=/sbin:/bin:/usr/sbin:/usr/bin", NULL };
/*
 * all fields must be there even if NULL or 0
 * separate by ONLY ONE space between field
 * separate record by ONLY ONE newline and for
 * the last record ALSO need a newline
 */
struct line_record {
	char func[FUNC_NAME_LEN];

	/*
	 * start_offset: offset to instruction where
	 * the measuring begin, including this
	 *
	 * end_offset:   offset to instruction where
	 * the measuring end, including this
	 *
	 * when start_offset = end_offset
	 * meaning only measuring this instruction
	 */
	char start_offset[OFFSET_LEN];
	char end_offset[OFFSET_LEN];

	/*
	 * only care target process, if NULL does't care
	 */
	char proc_comm[PROC_COMM_SIZE];

	/*
	 * when time consumption bigger or equal to
	 * this allows printk, if 0 printk always
	 * in ns
	 */
	char duration_threshold[DURATION_THRESHOLD_LEN];
};

struct kprobe_record {
	struct line_record *line_rec;
	struct kprobe head_kp;
	int head_ok;
	struct kprobe tail_kp;
	int tail_ok;
	unsigned long start_time;
	unsigned long end_time;
	int start_offset;
	int end_offset;
	unsigned long time;
	char *proc_comm;
	unsigned long a1, a2, a3, a4;
};

static int bytes_read, tot_records;
static char file_name[FILE_NAME_LEN];
module_param_string(file_name, file_name, MAX_SIZE, 0);

static char *buf;
static struct line_record *all_records;
static struct kprobe_record *kp_records;

static void display_all_kprobes(void)
{
	int i;

	for (i = 0; i < tot_records; ++i) {
		printk(KERN_INFO "kprobe %d:\n", i);
		printk(KERN_INFO " head kp addr: %lx\n", (unsigned long)kp_records[i].head_kp.addr);
		printk(KERN_INFO " tail kp addr: %lx\n", (unsigned long)kp_records[i].tail_kp.addr);
		printk(KERN_INFO " start offset: %d\n", kp_records[i].start_offset);
		printk(KERN_INFO "   end offset: %d\n", kp_records[i].end_offset);
		printk(KERN_INFO "         time: %lu\n", kp_records[i].time);
		printk(KERN_INFO "    proc_comm: %s\n", kp_records[i].proc_comm);
	}
}

static int handler_pre(struct kprobe *kp, struct pt_regs *regs)
{
	unsigned long tmp_start_time = ktime_get_ns();
	struct kprobe_record *kpr =
		container_of(kp, struct kprobe_record, head_kp);
	kpr->start_time = tmp_start_time;

	if (kpr->start_offset == 0) {
		kpr->a1 = regs->di;
		kpr->a2 = regs->si;
		kpr->a3 = regs->dx;
		kpr->a4 = regs->cx;
	}
	return 0;
}

static void save_dmesg(void)
{
	call_usermodehelper(argv[0], argv, envp, UMH_NO_WAIT);
}

static void handler_post(struct kprobe *kp, struct pt_regs *regs, unsigned long flags)
{
	unsigned long tmp_end_time = ktime_get_ns();
	struct kprobe_record *kpr;
	int flag = 1;

	if (kp->pre_handler)
		kpr = container_of(kp, struct kprobe_record, head_kp);
	else
		kpr = container_of(kp, struct kprobe_record, tail_kp);
	kpr->end_time = tmp_end_time;

	if (current && kpr->proc_comm &&
		strcmp(current->comm, kpr->proc_comm) != 0) {
		flag = 0;
	}
	if ((kpr->end_time - kpr->start_time) < kpr->time) {
		flag = 0;
	}

	if (flag) {
		if (kpr->start_offset)
			printk(KERN_INFO "comm: %s id: %ld time: %lu\n", current->comm,
				   kpr - kp_records, kpr->end_time - kpr->start_time);
		else
			printk(KERN_INFO "comm: %s id: %ld time: %lu a1: %lx a2: %lx a3: %lx a4: %lx\n", current->comm,
				   kpr - kp_records, kpr->end_time - kpr->start_time,
				   kpr->a1, kpr->a2, kpr->a3, kpr->a4);
		save_dmesg();
	}
}

static void unregister_record_kprobes(void)
{
	int i;

	for (i = 0; i < tot_records; ++i) {
		if (kp_records[i].head_ok)
			unregister_kprobe(&kp_records[i].head_kp);
		if (kp_records[i].tail_ok)
			unregister_kprobe(&kp_records[i].tail_kp);
	}
}

/*
 * register kprobes in kp_records
 */
static int register_record_kprobes(void)
{
	int i, ret = 0, res;
	struct line_record *tmp;

	for (i = 0; i < tot_records; ++i) {
		tmp = &all_records[i];
		kp_records[i].line_rec = tmp;
		res = kstrtoint(tmp->start_offset, 10, &kp_records[i].start_offset);
		if (res < 0) {
			printk(KERN_WARNING "kstrtoint failed: start_offset id: %d\n", i);
			return -1;
		}
		res = kstrtoint(tmp->end_offset, 10, &kp_records[i].end_offset);
		if (res < 0) {
			printk(KERN_WARNING "kstrtoint failed: end_offset id: %d\n", i);
			return -1;
		}

		if (strcmp(tmp->proc_comm, "NULL") == 0)
			kp_records[i].proc_comm = NULL;
		else
			kp_records[i].proc_comm = (char*)&tmp->proc_comm;
		res = kstrtoul(tmp->duration_threshold, 10, &kp_records[i].time);
		if (res < 0) {
			printk(KERN_WARNING "kstrtoul failed: time id: %d\n", i);
			return -1;
		}

		if (kp_records[i].start_offset == kp_records[i].end_offset &&
			kp_records[i].start_offset == -1) {
			kp_records[i].head_kp.symbol_name = tmp->func;
			kp_records[i].head_kp.pre_handler = handler_pre;
			kp_records[i].head_kp.post_handler = handler_post;
		}
		else {
			kp_records[i].head_kp.symbol_name = tmp->func;
			kp_records[i].head_kp.offset = kp_records[i].start_offset;
			kp_records[i].head_kp.pre_handler = handler_pre;
			kp_records[i].head_kp.post_handler = NULL;

			kp_records[i].tail_kp.symbol_name = tmp->func;
			kp_records[i].tail_kp.offset = kp_records[i].end_offset;
			kp_records[i].tail_kp.pre_handler = NULL;
			kp_records[i].tail_kp.post_handler = handler_post;

			ret = register_kprobe(&kp_records[i].tail_kp);
			if (ret < 0) {
				printk(KERN_INFO "failed to register tail kprobe: %d\n", i);
				return ret;
			}
			else
				kp_records[i].tail_ok = 1;
		}

		ret = register_kprobe(&kp_records[i].head_kp);
		if (ret < 0) {
			printk(KERN_INFO "failed to register head kprobe: %d\n", i);
			return ret;
		}
		else
			kp_records[i].head_ok = 1;
	}

	return ret;
}

/*
 * given field_cur number, return addr
 * of this field in line_record
 * maybe a better implement in the future
 */
void* get_field_addr(int field_cur, struct line_record *rec)
{
	switch (field_cur) {
	case 0:
		return rec->func;
	case 1:
		return rec->start_offset;
	case 2:
		return rec->end_offset;
	case 3:
		return rec->proc_comm;
	case 4:
		return rec->duration_threshold;
	}

	return NULL;
}

/*
 * copy one string in buf to all_records
 */
void copy_field(int which_record, int which_field, int field_start, int field_end)
{
	int i;
	char *tmp_field = get_field_addr(which_field, &all_records[which_record]);

	for (i = field_start; i <= field_end; ++i) {
		tmp_field[i - field_start] = buf[i];
	}
}

/*
 * convert raw buf to records
 */
static void process_record(void)
{
	int field_start, field_end;
	int global_curr, record_curr, field_curr;

	global_curr = record_curr = field_curr = 0;
	field_start = 0;

	while (global_curr <= bytes_read - 2) {
		if (buf[global_curr] == '\n' || global_curr == (bytes_read - 2)) {
			field_end = global_curr - 1;
			copy_field(record_curr, field_curr, field_start, field_end);

			field_curr = 0;
			field_start = global_curr + 1;

			record_curr++;
		}

		if (buf[global_curr] == ' ') {
			field_end = global_curr - 1;
			copy_field(record_curr, field_curr, field_start, field_end);

			field_curr++;
			field_start = global_curr + 1;
		}
		global_curr++;
	}
	tot_records = record_curr;
}

void display_all_records(void)
{
	int i;
	for (i = 0; i < tot_records; ++i) {
		printk(KERN_INFO "record %d:\n", i);
		printk(KERN_INFO " field 1: %s\n", all_records[i].func);
		printk(KERN_INFO " field 2: %s\n", all_records[i].start_offset);
		printk(KERN_INFO " field 3: %s\n", all_records[i].end_offset);
		printk(KERN_INFO " field 4: %s\n", all_records[i].proc_comm);
		printk(KERN_INFO " field 5: %s\n", all_records[i].duration_threshold);
	}
}

static int __init ktime_snoop_init_module(void)
{
	struct file *filep;
	buf = kmalloc(MAX_SIZE, GFP_KERNEL);
	all_records = kmalloc(MAX_SIZE, GFP_KERNEL);
	kp_records = kmalloc(sizeof(struct kprobe_record) * MAX_RECORD, GFP_KERNEL);

	if (!buf || !all_records || !kp_records) {
		printk(KERN_ALERT "failed to allocate memory\n");
		return -ENOMEM;
	}

	memset(buf, 0, MAX_SIZE);
	memset(all_records, 0, MAX_SIZE);
	memset(kp_records, 0, sizeof(struct kprobe_record) * MAX_RECORD);

	filep = filp_open(file_name, O_RDONLY, 0);
	if (!filep || IS_ERR(filep)) {
		printk(KERN_ERR "failed to open file: %s\n", file_name);
		return -ENOENT;
	}

	bytes_read = kernel_read(filep, buf, MAX_SIZE - 1, &filep->f_pos);
	if (bytes_read < 0) {
		printk(KERN_ERR "failed to read file: %s\n", file_name);
		filp_close(filep, NULL);
		return -EIO;
	}

	/*
	 * for debug only
	 */
	printk(KERN_INFO "file contents:\n%s", buf);
	process_record();
	register_record_kprobes();

	/*
	 *for debug ONLY
	 */
	display_all_records();
	display_all_kprobes();

	filp_close(filep, NULL);

	return 0;
}

static void __exit ktime_snoop_exit_module(void)
{
	unregister_record_kprobes();
	kfree(buf);
	kfree(all_records);
	kfree(kp_records);

	printk(KERN_INFO "ktime snoop module unloaded\n");
}

module_init(ktime_snoop_init_module);
module_exit(ktime_snoop_exit_module);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Qiyuan Pu");
MODULE_DESCRIPTION("measuring time of any part of kernel function");
