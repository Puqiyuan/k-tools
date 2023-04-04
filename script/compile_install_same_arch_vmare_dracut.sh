#set no need root password for username
echo $1 #username
echo $2 #ip
echo $3 #kernel dir
echo $4 #def config
echo $5 #threads
echo $6 #password
echo $7 #how many times compile
echo $8 #tot times
echo $9 #git commit

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
	make $4
	make -j$5 LOCALVERSION=$version_str
	rm -rf $3/mod
	mkdir $3/mod
	make modules_install INSTALL_MOD_PATH=$3/mod -j$5
	cp arch/x86/boot/bzImage ./vmlinuz
	cd $3/mod/lib/modules/
	kver=`ls`
	echo kver:$kver
	if [ "$#" -eq 9 ]; then
	    #tar -cvzf $3/mod.tar.gz $kver
		tar cf - $kver | pigz -p $5 > $3/mod.tar.gz
	fi

	if [ "$#" -eq 8 ]; then
	    tar -cvzf $3/mod.tar.gz 4.19.190-pqy
	fi
	cd /lib/modules/
	res=`ls |grep pqy`
	sudo rm -rf $res
	cd -
	sudo mv $kver /lib/modules
	dracut -f --kver $kver ../../../initrd-pqy.img
#fi

cd

expect << __EOF
set timeout 600
spawn scp -r -o StrictHostKeyChecking=no $3/vmlinuz $3/vmlinux $3/initrd-pqy.img $3/mod.tar.gz $HOME/kernel_debug_tools/script/startup.sh $1@$2:~
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
./install_same_arch_vmare_dracut $1 $2 $6
