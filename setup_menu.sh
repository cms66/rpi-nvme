# Setup main menu
# TODO
# - 

# set -e

# Error handler
handle_error()
{
	echo "Something went wrong!"
	echo "$(caller): ${BASH_COMMAND}"
}

# Set the error handler to be called when an error occurs
trap handle_error ERR

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
repo="rpi-nvme"
export repo
reposcr=$(getcwd)
# reposcr=$(pwd -P)
export reposcr

show_main_menu()
{
	clear
	printf "Setup Main menu - $(hostname)\n--------------\n\
1) Hardware \n\
2) NFS \n\
3) Security \n\
4) OpenMPI \n\
5) OpenCV \n\
6) SDM \n\
7) Update setup \n\
8) Update system \n\
9) System summary \n"
}

show_main_menu
read -p "Select option or x to exit: " n

# Run as root so using absolute path 
while [ $n != "x" ]; do
	case $n in
		1) sh $usrpath/.pisetup/$repo/setup_hardware.sh;;
		2) sh $usrpath/.pisetup/$repo/setup_nfs.sh;;
		3) sh $usrpath/.pisetup/$repo/setup_security.sh;;
		4) sh $usrpath/.pisetup/$repo/setup_openmpi.sh;;
		5) sh $usrpath/.pisetup/$repo/setup_opencv.sh;;
    		6) sh $usrpath/.pisetup/$repo/setup_sdm.sh;;
    		7) sh $usrpath/.pisetup/$repo/setup_git_pull_setup.sh;;
    		8) sh $usrpath/.pisetup/$repo/setup_update_system.sh;;
    		9) sh $usrpath/.pisetup/$repo/setup_system_summary.sh;;    
		*) read -p "invalid option - press enter to return to menu" errkey;;
	esac
	show_main_menu
	read -p "Select option or x to exit: " n
done
