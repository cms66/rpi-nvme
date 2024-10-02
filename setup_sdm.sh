# SDM Drive Imager
# TODO
# - Save/read settings from /etc/sdm/custom.conf
# - Add option for install location (default = /usr/local)
# - Add option for setting image directory (defaults to local share for performance)
# - Add option for version change e.g Bullseye/Bookworm
# - Add check for latest update for current and last versions

imgdir=$usrpath/share$pinum/sdm/images
# Latest images
verlatest=$(curl -s https://downloads.raspberrypi.org/operating-systems-categories.json | grep "releaseDate" | head -n 1 | cut -d '"' -f 4)
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
 3) Download latest images \n\
 4) Customize image \n\
 5) Burn image \n"
}

install_local()
{
	# Default setup - install to /usr/local
	#curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | bash
 	# Create directories for images
 	mkdir -p $imgdir/current
  	mkdir -p $imgdir/latest
   	mkdir -p $imgdir/archive
    	chown -R $imgdir
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
      #ufw allow from $localnet to $localnet
	fi
	read -p "SDM - Server install finished, press enter to return to menu" input
}

download_latest_images()
{
	# Replace uncustomized latest images
  	rm $imgdir/latest/*.img
	# Download latest images and extract
	wget -P $imgdir/latest $url64lite
 	wget -P $imgdir/latest $url64desk
  	wget -P $imgdir/latest $url32lite
   	wget -P $imgdir/latest $url32desk
    	unxz $imgdir/latest/*.xz
     	read -p "Downloads to $imgdir/latest complete, press enter to return to menu" input
}

customize_image()
{
	# Select image
	read -p "Password for $usrname: " usrpass
	sdm --customize --plugin user:"adduser=$usrname|password=$usrpass" --plugin L10n:host --plugin disables:piwiz --expand-root --regen-ssh-host-keys --restart 
}

burn_image()
{

}

show_sdm_menu
read -p "Select option or x to exit to main menu: " n
while [ $n != "x" ]; do
	case $n in
		1) install_local;;
		2) install_server;;
		3) download_latest_images;;
		4) customize_image;;
		5) burn_image;;  
  		*) read -p "invalid option - press enter to continue" errkey;;
	esac
	show_sdm_menu
	read -p "Select option or x to exit to main menu: " n
done


#read -p "Path to image directory (press enter for default = $usrpath/share$pinum/sdm/): " userdir
#imgdir=${userdir:="$usrpath/share$pinum/sdm/"}
#mkdir $imgdir

