#!/bin/bash

# echo $1: the file that product by kernel_config_compare.sh
# echo $2: the file ready to weed out configured option
rm missing.txt really_missing.txt repeated.txt -rf
grep -e "- " $1 |cut -c 3- > missing.txt
tot_cnt=`cat $2 |wc -l`
while IFS= read -r line
do
	cnt=0
	token=`echo $line |awk -F "=" '{print $1}'`=
	while IFS= read -r option
	do
		if [[ $option == *$token*  ]]; then
			echo $token >> repeated.txt
			break
		else
			((cnt=cnt+1))
		fi
	done < "$2"
	if [ $cnt -eq $tot_cnt ]; then
		echo $line >> really_missing.txt
	fi
done < "missing.txt"
