#!/bin/bash

# echo $1 source dir

tot_line=0
for f in $(find $1 -name '*.c' -or -name '*.S' -or -name '*.cpp' -or -name '*.cc' -or -name '*.h' -or -name '*.s');
do
	current_lines=`cat $f |wc -l`
	((tot_line+=$current_lines))
done

echo all lines: $tot_line
