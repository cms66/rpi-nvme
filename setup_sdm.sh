# SDM Drive Imager
# TODO
# - Check latest version from https://downloads.raspberrypi.org/operating-systems-categories.json
# - Add option for install location (default = /usr/local)
# - Add option for setting image directory (defaults to local share for performance)

imgdir=$usrpath/share$pinum/sdm/
# Latest images
verlatest="2024-07-04"
url64lite=https://downloads.raspberrypi.org//raspios_lite_arm64/images/raspios_lite_arm64-$verlatest/$verlatest-raspios-bookworm-arm64-lite.img.xz
url64desk=https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-$verlatest/$verlatest-raspios-bookworm-arm64.img.xz
url32lite=https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-$verlatest/$verlatest-raspios-bookworm-armhf-lite.img.xz
url32desk=https://downloads.raspberrypi.com/raspios_armhf/images/raspios_armhf-$verlatest/$verlatest-raspios-bookworm-armhf.img.xz

show_sdm_menu()
{
	clear
	printf "SDM Drive Imager setup menu \n----------\n\
 1) Install - local \n\
 2) Install - server \n\
 3) Download latest images \n"
}

install_local()
{
	# Default setup
	curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | bash
 	download_latest_images
}

install_server()
{
	install_local
 	if grep -F "/usr/local" "/etc/exports"; then
  		echo "export exists"
  	else
		  echo "/usr/local $localnet(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
  		exportfs -ra
      ufw allow from $localnet to $localnet
	fi
	read -p "SDM - Server install finished, press enter to return to menu" input
}

download_latest_images()
{
	# Download latest images and extract
	wget -P $imgdir $url64lite
 	wget -P $imgdir $url64desk
  	wget -P $imgdir $url32lite
   	wget -P $imgdir $url32desk
    	unxz $imgdir/*.xz
}

show_sdm_menu
read -p "Select option or x to exit to main menu: " n
while [ $n != "x" ]; do
	case $n in
		1) install_local;;
		2) install_server;;
		3) download_latest_images;;
  		*) read -p "invalid option - press enter to continue" errkey;;
	esac
	show_sdm_menu
	read -p "Select option or x to exit to main menu: " n
done


#read -p "Path to image directory (press enter for default = $usrpath/share$pinum/sdm/): " userdir
#imgdir=${userdir:="$usrpath/share$pinum/sdm/"}
#mkdir $imgdir

