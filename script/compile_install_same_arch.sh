# you need first ssh target machine to use this script
# and set no need root password for username
echo $1 #username
echo $2 #ip
echo $3 #kernel dir
echo $4 #def config
echo $5 #threads
echo $6 #password

sudo yum install expect -y
sudo apt install expect -y
pwd_script=`pwd`
cd $3
make $4
make -j$5 LOCALVERSION=-pqy
rm -rf $3/mod
mkdir $3/mod
make modules_install INSTALL_MOD_PATH=$3/mod -j32
cd $3/mod/lib/modules/
tar -cvzf $3/mod.tar.gz 4.19.190-pqy

expect << __EOF
set timeout 30
spawn scp -o StrictHostKeyChecking=no $3/vmlinuz $3/vmlinux $3/mod.tar.gz ./startup.sh $1@$2:~
expect "*password:"
send "$6\r"
expect of
__EOF

rm $3/mod $3/mod.tar.gz -rf
cd $pwd_script
./install_same_arch $1 $2 $6
