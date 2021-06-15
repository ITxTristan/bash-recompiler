#!/bin/bash

#Tristan Martin
#6/15/21
#Bash Recompiler

#Print original bash version
original=`bash --version | awk 'NR==1{print $1, $2, $3, $4, $5}'`
echo "[+] Original Bash Version: $original [+]"
sleep 2

#Handle user supplied arguments
while getopts v: flag
do
	case "${flag}" in
		v) version=${OPTARG};;
		*) echo "You have supplied an invalid option"
		   echo "Syntax: ./recompile.sh -v <version> -q <yes/no>"
	           exit 1
	esac
done 

#Crude detection of package manager
echo "[+] Grabbing Necessary Dependencies [+]"
if [ -f /etc/redhat-release ]; then
	yum install wget gcc pv -y > /dev/null 2>&1
elif [ -f /etc/lsb-release ]; then
	apt-get install wget gcc pv -y > /dev/null 2>&1
fi

echo "[+] Downloading Requested Version [+]"

#Make directory to store tar.gz file and source code
mkdir -p /root/bash-$version
cd /root/bash-$version

#GET request for tar.gz
wget -q https://ftp.gnu.org/gnu/bash/bash-$version.tar.gz
tar -xzf /root/bash-$version/bash-$version.tar.gz
cd /root/bash-$version/bash-$version

#Compile Bash
echo "[+] Recompiling Bash [+]"
./configure --prefix=/usr --bindir=/bin --without-bash-malloc --with-installed-readline --disable-net-redirections > /dev/null 2>&1
echo "[+] Installing Requested Version [+]"
make -s > /dev/null 2>&1 && make -s install > /dev/null 2>&1

recompiled=`bash --version | awk 'NR==1{print $1, $2, $3, $4, $5}'`
echo "[+] Current Bash Version: $recompiled [+]"

#Add some clean-up here for tar.gz files
rm -rf /root/bash-$version
