#!/bin/bash

kernel_version=`uname -r`

if [[ $kernel_version == *"pqy"* ]]; then
    echo changed
    exit
fi

grub_filename=`sudo find /boot/ -name grub.cfg`
vmlinuz_filename=vmlinuz-`uname -r`
sudo cp $grub_filename $grub_filename.bak
sudo cp /boot/$vmlinuz_filename /boot/vmlinuz-pqy
sudo sed -i 's/linux.*root/linux \/vmlinuz-pqy root/g' $grub_filename
sync
sudo reboot
