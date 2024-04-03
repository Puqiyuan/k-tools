#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/printk.h>

static struct kprobe kp;

/* kprobe pre_handler: called just before the probed instruction is executed */
int handler_pre(struct kprobe *p, struct pt_regs *regs)
{
	char *ptr = (char*)1234;
    //printk(KERN_INFO "Hello\n");
	/*
	printk("bio: %lx bytes: %lu\n", regs->di, regs->si);
	printk("bio: %lx bytes: %lu\n", regs->di, regs->si);
	printk("bio: %lx bytes: %lu\n", regs->di, regs->si);
	*/
	//trigger crash, in crash get regs->di and others
	printk("char: %c\n", *ptr);
    return 0;
}

/* kprobe post_handler: called after the probed instruction is executed */
void handler_post(struct kprobe *p, struct pt_regs *regs, unsigned long flags)
{
    /* Nothing here */
}

/* kprobe fault_handler: called if an exception occurred in the probed instruction */
int handler_fault(struct kprobe *p, struct pt_regs *regs, int trapnr)
{
    printk(KERN_INFO "fault_handler: Detected trap %d, errno %ld\n", trapnr, regs->si);
    return 0;
}

static int __init kprobe_init(void)
{
    int ret;

    kp.pre_handler = handler_pre;
    kp.post_handler = handler_post;
    kp.fault_handler = handler_fault;
    kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("bio_advance");
	//kp.symbol_name = "sys_read";

	if (!kp.addr) {
        printk(KERN_INFO "Failed to find address of sys_read\n");
        return -1;
    }
    ret = register_kprobe(&kp);
    if (ret < 0) {
        printk(KERN_INFO "Failed to register kprobe\n");
        return ret;
    }
    printk(KERN_INFO "Planted kprobe at %p\n", kp.addr);

    return 0;
}

static void __exit kprobe_exit(void)
{
    unregister_kprobe(&kp);
    printk(KERN_INFO "kprobe at %p unregistered\n", kp.addr);
}

module_init(kprobe_init);
module_exit(kprobe_exit);

MODULE_LICENSE("GPL");
