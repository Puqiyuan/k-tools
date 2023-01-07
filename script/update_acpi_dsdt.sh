# 1, requires your modified dsl file named dsdt-modified.dsl in $HOME dir
#    especially OEM version need update to work
# 2, requires initrd /acpi_test_initrd in grub.cfg
# 3, the argu is name of original initrd
if [ "$#" -eq 0 ];then
	echo need argu
	exit
fi
cd /tmp
cp $HOME/dsdt-modified.dsl /tmp
rm -rf kernel
mkdir -p kernel/firmware/acpi
iasl -sa dsdt-modified.dsl
cp dsdt-modified.aml kernel/firmware/acpi
find kernel | cpio -H newc --create > ./acpi_test_initrd
sudo cp /boot/$1 .
sudo cat ./$1 >> ./acpi_test_initrd
sudo cp ./acpi_test_initrd /boot
#sudo reboot
