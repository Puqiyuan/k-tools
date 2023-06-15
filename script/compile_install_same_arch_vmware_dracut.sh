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
echo ${10} #default kernel version 

version_str=-pqy

if [ "${10}" == "NULL" ]; then
    version_str=-pqy-$9
else
    version_str="${10}"
fi

res=`expect -v |grep bash`
if [[ ! -z "$res" ]]
then
	sudo yum install expect -y
	sudo apt install expect -y
fi

pwd_script=`pwd`
echo version_str:$version_str
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
tar cf - $kver | pigz -p $5 > $3/mod.tar.gz
cd

expect << __EOF
set timeout 600
spawn scp -r -o StrictHostKeyChecking=no $3/vmlinuz $3/vmlinux $3/mod.tar.gz $HOME/kernel_debug_tools/script/startup.sh $1@$2:~
expect "*password:"
send "$6\r"
expect of
__EOF

cd $pwd_script
./install_same_arch_vmware_dracut $1 $2 $6 $kver
