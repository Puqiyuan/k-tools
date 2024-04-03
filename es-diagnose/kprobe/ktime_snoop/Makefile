obj-m := ktime_snoop.o
KDIR := /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

default:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

release:
	rm -rf release
	mkdir release
	make default
	cp save_dmesg ktime_snoop.ko timing.txt usage release
	tar cvzf release.tar.gz release
	rm -rf release
	make clean

test:
	sudo dmesg -C
	make
	sudo insmod ktime_snoop.ko file_name="./timing.txt"
	sudo dmesg -w
