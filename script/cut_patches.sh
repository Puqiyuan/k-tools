#!/bin/bash
echo commit number: $1 #commit number
echo where machine info: $2 #machine info
echo kernel path: $3 #kernel source path
echo kernel config: $4
echo core number: $5
echo offset patch: $6 #optional, default is 0, apply from where
echo patch number: $7 #optional, default is all patches, total patches that you need to apply

script_dir=$PWD

rm -rf $HOME/linux-4.19-loongson-test
cd $3
echo clean...
make clean -j32
cd $HOME
echo coping...
cp -r $3 $HOME/linux-4.19-loongson-test/ 

cd $HOME/linux-4.19-loongson-test/
rm *.patch -f

offset=0
all_patch_number=`git format-patch $1 |wc -l`
#total pathes that you need to apply
patch_number=$all_patch_number
if [ "$#" -eq 7  ]; then
    offset=$6
    patch_number=$7
fi
echo patch number: $patch_number #debug

cd $script_dir
machine_number=`cat $2 |wc -l`
echo machine number: $machine_number #debug

space=$((patch_number / machine_number))
test_space_product=$((space * machine_number))
if [ $test_space_product -ne $patch_number ]; then
    space=$(($space + 1))
fi
echo space number: $space #debug

cd $HOME/linux-4.19-loongson-test/
#remove leading zero
for FILE in `ls *.patch`; do mv $FILE `echo $FILE | sed -e 's:^0*::'`; done

cursor_num=1
cnt=1
cd $script_dir
while IFS= read -r line
do
    username=`echo $line |awk '{print $1}'`
    ip=`echo $line |awk '{print $2}'`
    passwd=`echo $line |awk '{print $3}'`

    stop_number=$((cnt * space + offset))
    if [[ $stop_number -ge $all_patch_number ]]; then
	stop_number=$all_patch_number
    fi

    #TODO improve: just every space to am patch, no need start from
    #the first patch every time
    cd $HOME/linux-4.19-loongson-test/
    git reset --hard $1
    while [ $cursor_num -le $stop_number ]
    do
	echo $cursor_num patch applying...
	git am $cursor_num-*.patch
	((cursor_num++))
    done
    ((cursor_num--))
    localversion_str=$cursor_num-`cat $cursor_num-*.patch |head -1 |awk '{print $2}' |head -c 10`
    echo $localversion_str
    echo $cnt machine ready to deploy...
    sleep 3
    cd $script_dir
    ./compile_install_same_arch.sh $username $ip $HOME/linux-4.19-loongson-test/ $4 $5 $passwd $cnt $machine_number $localversion_str
    
    cnt=$((cnt + 1))
    cursor_num=1
    cd $script_dir
done < "$2"
