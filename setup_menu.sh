# Setup main menu
# Check/Run other setup scripts
# TODO
# - 

# create/export variables for other scripts
usrname=$(logname)
export usrname
usrpath="/home/$usrname"
export usrpath
pinum=$(hostname | tr -cd '[:digit:].')
export pinum
localnet=$(ip route | awk '/proto/ && !/default/ {print $1}')
export localnet
pimodel=$(cat /sys/firmware/devicetree/base/model)
export pimodel
pirev=$(cat /proc/cpuinfo | grep 'Revision' | awk '{print $3}' | sed 's/^1000//')
export pirev
pimem=$(free -mt)
export pimem
osarch=$(getconf LONG_BIT)
export osarch

show_main_menu()
{
	clear
	printf "Setup Main menu \n--------------\n\
1) Hardware \n\
2) NFS \n\
3) Security \n\
4) OpenMPI \n\
5) OpenCV \n\
6) Update setup \n\
7) Update system \n\
8) System summary \n"
}

show_main_menu
read -p "Select option or x to exit: " n

# Run as root so using absolute path 
while [ $n != "x" ]; do
	case $n in
		1) sh $usrpath/.pisetup/rpi-nvme/setup_hardware.sh;;
		2) sh $usrpath/.pisetup/rpi-nvme/setup_nfs.sh;;
		3) sh $usrpath/.pisetup/rpi-nvme/setup_security.sh;;
		4) sh $usrpath/.pisetup/rpi-nvme/setup_openmpi.sh;;
		5) sh $usrpath/.pisetup/rpi-nvme/setup_opencv.sh;;
  	6) sh $usrpath/.pisetup/rpi-nvme/setup_git_pull_setup.sh;;
    7) sh $usrpath/.pisetup/rpi-nvme/setup_update_system.sh;;
    8) sh $usrpath/.pisetup/rpi-nvme/setup_system_summary.sh;;
		*) read -p "invalid option - press enter to return to menu" errkey;;
	esac
	show_main_menu
	read -p "Select option or x to exit: " n
done
