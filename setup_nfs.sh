# NFS
# TODO
# - Automount not working with Desktop image - Use options nfs defaults,user,exec,noauto,x-systemd.automount 0 0
# - Add options to update local/server mounts from updated tgz

show_nfs_menu()
{
	clear
	printf "NFS setup menu \n----------\n\
 1) Setup local Server \n\
 2) Add local export \n\
 3) Add Remote mount \n"
}

# Setup local Server
# Creates default share /var/nfs-export + local mount
setup_local_server()
{
	apt-get -y install nfs-kernel-server
	read -p "Path to directory containing share (press enter for default = /var/): " userdir
	nfsdir=${userdir:="/var/"}
 	tar -xvzf $usrpath/.pisetup/rpi-home/nfs-export.tgz -C $nfsdir
  	nfspath="${nfsdir}nfs-export" 
	mkdir $usrpath/share$pinum
	chown -R $usrname:$usrname $nfspath
	echo "$nfspath 192.168.0.0/24(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
	echo "$nfspath $usrpath/share$pinum    none	bind	0	0" >> /etc/fstab
	exportfs -ra
	mount -a
	ufw allow from $localnet to any port nfs
	read -p "NFS Server setup done, press any key to return to menu" input
}

# Add local export
add_local_export()
{
	read -p "NFS local export TODO, press enter to return to menu" input
}

# Add remote mount
add_remote_mount()
{
	read -p "Remote node (integer only): " nfsrem
	read -p "Full path to remote directory (press enter for default = /var/nfs-export): " userdir
	nfsdir=${userdir:="/var/nfs-export"}
	mkdir $usrpath/share$nfsrem
	chown $usrname:$usrname $usrpath/share$nfsrem
	echo "pinode-$nfsrem.local:$nfsdir $usrpath/share$nfsrem    nfs defaults,user,exec,noauto,x-systemd.automount 0 0" >> /etc/fstab
	mount -a
	read -p "NFS remote mount done, press enter to return to menu" input
}

show_nfs_menu
read -p "Select option or x to exit to main menu: " n
while [ $n != "x" ]; do
	case $n in
	    1) setup_local_server;;
	    2) add_local_export;;
	    3) add_remote_mount;;
	    *) read -p "invalid option - press enter to continue" errkey;;
	esac
	show_nfs_menu
	read -p "Select option or x to exit to main menu: " n
done
