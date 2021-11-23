#!/bin/bash

#echo $1 base config
#echo $2 comparison config

# output: Compared with the comparison file, what are the basic files added or missing?

grep = $1 |sort > base.cfg
grep = $2 |sort > compare.cfg

tot_cnt=`cat compare.cfg |wc -l`
echo ---ADDED---
while IFS= read -r line_base
do
	cnt=0
	while IFS= read -r line_compare
	do
		if [[ "$line_base"  == "$line_compare" ]];then
			break
		else
			((cnt=cnt+1))
		fi
	done < "compare.cfg"
	if [ $cnt -eq $tot_cnt ]; then
		echo + $line_base
	fi
done < "base.cfg"

echo ---MISSING---
tot_cnt=`cat base.cfg |wc -l`
while IFS= read -r line_compare
do
	cnt=0
	while IFS= read -r line_base
	do
		if [[ "$line_base" == "$line_compare" ]]; then
			break
		else
			((cnt=cnt+1))
		fi
	done < "base.cfg"
	if [ $cnt -eq $tot_cnt ]; then
		echo - $line_compare
	fi
done < "compare.cfg"

