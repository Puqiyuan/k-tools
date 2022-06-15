#set no need root password for username
echo $1 #username
echo $2 #ip
echo $3 #kernel dir
echo $4 #def config
echo $5 #threads
echo $6 #password
echo $7 #how many times compile
echo $8 #tot times
echo ${10} #port

arch="loongarch"
toolchain="/home/puqiyuan/11.02-gcc/bin/loongarch64-linux-gnu-"
version_str=-pqy

if [ "$#" -eq 9 ]; then
    version_str=-pqy-$9
fi

res=`expect -v |grep bash`
if [[ ! -z "$res" ]]
then
	sudo yum install expect -y
	sudo apt install expect -y
fi

pwd_script=`pwd`

#if the code is changed, it needs to be re-compile
#if [[ "$7" -eq 1 ]];
#then
	cd $3
	make ARCH=$arch CROSS_COMPILE=$toolchain $4
	make ARCH=$arch CROSS_COMPILE=$toolchain -j$5 LOCALVERSION=$version_str
	rm -rf $3/mod
	mkdir $3/mod
	make modules_install INSTALL_MOD_PATH=$3/mod -j$5
	cd $3/mod/lib/modules/
	if [ "$#" -eq 9 ]; then
	    tar -cvzf $3/mod.tar.gz 4.19.190-pqy-$9
	fi

	if [ "$#" -eq 8 ]; then
	    tar -cvzf $3/mod.tar.gz 4.19.190-pqy
	fi
#fi

cd

expect << __EOF
set timeout 600
spawn scp -P ${10} -r -o StrictHostKeyChecking=no $3/vmlinuz $3/vmlinux $3/mod.tar.gz $HOME/kernel_debug_tools/script/startup.sh $1@$2:~
expect "*password:"
send "$6\r"
expect of
__EOF

if [[ "$7" -eq "$8" ]]
then
	#rm $3/mod $3/mod.tar.gz -rf
	echo nothing
fi
cd $pwd_script
./install_same_arch_with_port $1 $2 $6 ${10}
