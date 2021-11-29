#!/bin/bash

# function: given the file product by kernel_config_compare.sh, output the Kconfig desc to a file named config.desc
# echo $1 the file that product by kernel_config_compare.sh
# echo $2 the kernel source code

rm -rf config.desc
while IFS= read -r line
do
    if [[ "$line" == "---ADDED---"  ]]; then
		echo ---ADDED--- >> config.desc
    elif [[ "$line" == "---MISSING---"  ]]; then
		echo ---MISSING--- >> config.desc
    else
		echo $line >> config.desc
		conf_name=`echo $line |cut -c 10- |awk -F "=" '{print $1}'`
		kconfig_file=`grep $2 -e "config $conf_name\b" --include=Kconfig -Rn |awk -F ":" '{print $1}' |head -1`
		if [ -n "$kconfig_file" ]; then
			echo $kconfig_file >> config.desc
			start_line=`grep $2 -e "config $conf_name\b" --include=Kconfig -Rn |awk -F ":" '{print $2}' |head -1`
			tmp_end_line=`tail -n +$((start_line+1)) $kconfig_file |grep  -e "config " -n |head -1 |awk -F ":" '{print $1}'`
			end_line=$(($tmp_end_line+$start_line))
			sed -n "$start_line,$((end_line-1)) p" $kconfig_file >> config.desc
		fi
    fi
done < "$1"
