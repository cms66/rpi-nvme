# OpenMPI
# TODO
# - Firewall rules for Server install

# From version 5 32 bit OS is not supported
# Latest versions
url32=https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.6.tar.gz
url64=https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.5.tar.gz
ver32="4.1.6"
ver64="5.0.5"
if [ $osarch = "64" ]
then
	downlink=$url64
 	instver=$ver64
else
	downlink=$url32
	instver=$ver32
fi
show_mpi_menu()
{
	clear
	printf "MPI setup menu \n----------\n\
select setup option or x to exit \n\
1) Build/install - local \n\
2) Build/install - server \n\
3) Install - client \n\
4) Install - Python (mpi4py) - server\n\
5) Install - Munge - server\n\
6) Install -Slurm - server\n"
}

# 1 - Build/install local
install_local()
{
	cd $usrpath
	wget $downlink
	tar -xzf openmpi*.tar.gz
	cd openmpi-$instver
	./configure
	cores=$(nproc)
	make -j$cores all
	make install	
	ldconfig	
	cd $usrpath
	rm -rf openmpi*
	mpirun --version
	read -p "OpenMPI $instver - Local install finished, press enter to return to menu" input
}

# 2- Build/install on server
install_server()
{
	install_local
 	if grep -F "/usr/local" "/etc/exports"; then
  		echo "export exists"
  	else
		echo "/usr/local $localnet(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
  		exportfs -ra
	fi
 	ufw allow from $localnet to $localnet
	read -p "OpenMPI $instver - Server install finished, press enter to return to menu" input
}

# 3- Install to run from server
install_client()
{
	read -p "Remote node (integer only): " nfsrem
	read -p "Full path to remote directory (press enter for default = /usr/local): " userdir
	nfsdir=${userdir:="/usr/local"}
	mkdir -p $nfsdir
 	if grep -F $nfsdir "/etc/fstab"; then
  		echo "mount already exists"
    	else
		echo "pinode-$nfsrem.local:$nfsdir $nfsdir    nfs defaults" >> /etc/fstab
  	fi
	mount -a
 	#systemctl daemon-reload
	ldconfig
	mpirun --version
	read -p "OpenMPI $instver - Client install done, press enter to return to menu" input
}

# 4 - Install mpi4py
install_python_server()
{
 	# Install to shared directory /usr/local?
	git clone https://github.com/mpi4py/mpi4py.git
	cd mpi4py
	python setup.py build
	python setup.py install
	rm -rf mpi4py*
	read -p "mpi4py install done, press enter to return to menu" input
}

install_munge()
{
	# Create System group and user
	groupadd -r -g 991 munge
 	useradd -r -g munge -u 991 -d /var/lib/munge -s /sbin/nologin munge
  	# Install from Git
   	git clone https://github.com/dun/munge.git
	cd munge
 	./bootstrap
  	./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --runstatedir=/run
   	make
    	make check
	make install
 	# Security
 	chown munge:munge /etc/munge
  	chmod 0700 /etc/munge
 	chown munge:munge /var/lib/munge
  	chmod 0700 /var/lib/munge
 	chown munge:munge /var/log/munge
  	chmod 0700 /var/log/munge
 	chown munge:munge /run/munge
  	chmod 0755 /run/munge
   	# Run munge at startup
   	systemctl enable munge.service
	# Create or copy key
 	#read -p "munge install done, press enter to return to menu" input
 	
 	cp $usrpath/share1/munge.key /etc/munge/
  	chown munge:munge /etc/munge/munge.key
	#sudo -u munge /usr/sbin/mungekey --verbose
 	read -p "munge install done, press enter to return to menu" input
}

install_slurm()
{
	git clone https://github.com/SchedMD/slurm.git
 
	read -p "slurm install done, press enter to return to menu" input
}

show_mpi_menu
read -p "Select option or x to exit to main menu: " n
while [ $n != "x" ]; do
	case $n in
		1) install_local;;
		2) install_server;;
		3) install_client;;
		4) install_python_server;;
		5) install_munge;;
		6) install_slurm;;
  		*) read -p "invalid option - press enter to continue" errkey;;
	esac
	show_mpi_menu
	read -p "Select option or x to exit to main menu: " n
done
