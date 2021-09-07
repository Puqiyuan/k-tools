# you need first ssh target machine to use this script
# and set no need root password for username
echo $1 #username
echo $2 #ip
echo $3 #kernel dir
echo $4 #def config
echo $5 #threads
echo $6 #password
echo $7 #how many times compile
echo $8 #tot times

res=`expect -v |grep bash`
if [[ ! -z "$res" ]]
then
	sudo yum install expect -y
	sudo apt install expect -y
fi

pwd_script=`pwd`

if [[ "$7" -eq 1 ]];
then
	cd $3
	make $4
	make -j$5 LOCALVERSION=-pqy
	rm -rf $3/mod
	mkdir $3/mod
	make modules_install INSTALL_MOD_PATH=$3/mod -j32
	cd $3/mod/lib/modules/
	tar -cvzf $3/mod.tar.gz 4.19.190-pqy
fi

cd

expect << __EOF
set timeout 30
spawn scp -r -o StrictHostKeyChecking=no $HOME/kernel_debug_tools $3/vmlinuz $3/vmlinux $3/mod.tar.gz $HOME/kernel_debug_tools/script/startup.sh $1@$2:~
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
./install_same_arch $1 $2 $6
