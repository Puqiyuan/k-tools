#usage: ./grep_string_from_dmesg.sh "string you want to grep like this" &
#!/bin/bash

echo string you want to grep: $1
while true; do
	res=`dmesg |grep -e "$1"`
	if [[ ! -z "$res" ]]
	then
		dmesg > log.txt
		sudo dmesg -C
		break
	fi
done
