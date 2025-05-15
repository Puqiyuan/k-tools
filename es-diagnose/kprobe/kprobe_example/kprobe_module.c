#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/printk.h>

static struct kprobe kp1;

/* kprobe pre_handler: called just before the probed instruction is executed */
int handler_pre1(struct kprobe *p, struct pt_regs *regs)
{
	return 0;
}

/* kprobe post_handler: called after the probed instruction is executed */
void handler_post1(struct kprobe *p, struct pt_regs *regs, unsigned long flags)
{
}

/* kprobe fault_handler: called if an exception occurred in the probed instruction */
int handler_fault1(struct kprobe *p, struct pt_regs *regs, int trapnr)
{
	printk(KERN_INFO "fault_handler: Detected trap %d, errno %ld\n", trapnr, regs->si);
	return 0;
}

static int __init kprobe_init(void)
{
	int ret;

	kp1.pre_handler = handler_pre1;
	kp1.post_handler = handler_post1;
	kp1.fault_handler = handler_fault1;
	kp1.addr = (kprobe_opcode_t *)kallsyms_lookup_name("bio_advance");

	if (!kp1.addr) {
        	printk(KERN_INFO "Failed to find address of sys_read\n");
        	return -1;
    	}
    	ret = register_kprobe(&kp1);
    	if (ret < 0) {
        	printk(KERN_INFO "Failed to register kprobe\n");
        	return ret;
    	}
    	printk(KERN_INFO "Planted kprobe at %p\n", kp1.addr);

	return 0;
}

static void __exit kprobe_exit(void)
{
	printk(KERN_INFO "kprobe at %p unregistered\n", kp1.addr);
	unregister_kprobe(&kp1);
}

module_init(kprobe_init);
module_exit(kprobe_exit);

MODULE_LICENSE("GPL");
