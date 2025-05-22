#include <linux/module.h>
#include <linux/timer.h>
#include <linux/jiffies.h>

#include <asm/pvclock.h>
#include <asm/kvmclock.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Qiyuan Pu");
MODULE_DESCRIPTION("the kernel module that monitor rdtsc and pvti struct in guest");

struct per_cpu_timer_data {
	struct timer_list timer;
	int cpu;
};

static DEFINE_PER_CPU(struct per_cpu_timer_data, cpu_timer_data);

static void timer_callback(struct timer_list *t)
{
	struct per_cpu_timer_data *data = from_timer(data, t, timer);
	u64 tsc = rdtsc_ordered();
	struct pvclock_vcpu_time_info *src = this_cpu_pvti();

	if (src)
 		printk("cpu: %d tsc: %llu tsc_timestamp: %llu system_time: %llu tsc_to_system_mul: %u tsc_shift: %d\n",
		smp_processor_id(), tsc, src->tsc_timestamp, src->system_time, src->tsc_to_system_mul, src->tsc_shift);

	mod_timer(&data->timer, jiffies + HZ);
	return;
}

static int __init monitor_timer_init(void)
{
	int cpu;

	for_each_online_cpu(cpu) {
		struct per_cpu_timer_data *data = &per_cpu(cpu_timer_data, cpu);

		data->cpu = cpu;
		timer_setup_on_stack(&data->timer, timer_callback, 0);
		data->timer.expires = jiffies + HZ;
		add_timer_on(&data->timer, cpu);
	}

	printk("monitor per-cpu timer module registered\n");
	return 0;
}

static void __exit monitor_timer_exit(void)
{
	int cpu;

	for_each_online_cpu(cpu) {
		struct per_cpu_timer_data *data = &per_cpu(cpu_timer_data, cpu);
		del_timer_sync(&data->timer);
	}
	printk(KERN_INFO "monitor per-cpu timer module unloaded\n");
}

module_init(monitor_timer_init);
module_exit(monitor_timer_exit);
