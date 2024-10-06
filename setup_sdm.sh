# SDM Drive Imager
# TODO
# - Check for NFS shares
# - Save/read settings from custom.conf
# - Add option for install location (default = /usr/local)
# - Add option for setting image directory (defaults to local share for performance)
# - Add option for version change e.g Bullseye/Bookworm
# - Add check latest update for current and last versions

# Error handler
handle_error()
{
    #echo "An error occurred: $1"
    # Additional error handling code can go here
    echo "$(caller): ${BASH_COMMAND}\n"
}

# Set the error handler to be called when an error occurs
trap handle_error ERR

instdir="/usr/local/sdm" # Default installation directory (target for custom.conf)
imgdir="$usrpath/share$pinum/sdm/images" # Default image directory
# Latest images
verlatest=$(curl -s https://downloads.raspberrypi.org/operating-systems-categories.json | grep "releaseDate" | head -n 1 | cut -d '"' -f 4)
url64lite=https://downloads.raspberrypi.org//raspios_lite_arm64/images/raspios_lite_arm64-$verlatest/$verlatest-raspios-bookworm-arm64-lite.img.xz
url64desk=https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-$verlatest/$verlatest-raspios-bookworm-arm64.img.xz
url32lite=https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-$verlatest/$verlatest-raspios-bookworm-armhf-lite.img.xz
url32desk=https://downloads.raspberrypi.com/raspios_armhf/images/raspios_armhf-$verlatest/$verlatest-raspios-bookworm-armhf.img.xz

read_config()
{
	#cat $instdir/custom.conf
 	#readarray -t a < $instdir/custom.conf
  	#awk '{print NR,$0}' $instdir/custom.conf
	#mapfile -t arrconf < $instdir/custom.conf
	#for value in "${arrconf[@]}"; do
    	#	echo "$value"
	#done 
	conf=$instdir/custom.conf
 	#conf=$(grep -v ^\# $instdir/custom.conf)
	while IFS= read -r line
	do
    		key=${line%% *}
    		value=${line#* }
    		echo "Key: [$key]"
    		echo "Value: [$value]"
	done < "$conf"
 	#done < $(grep -v ^\# $instdir/custom.conf)
  	read -p "Current config, press enter to return to menu" input
}

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
	# Default setup - install to /usr/local/sdm
	#curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | bash
  	# Create directories for images
  	read -p "Path to image directory (press enter for default = $usrpath/share$pinum/sdm/images/): " userdir
	$imgdir=${userdir:="$usrpath/share$pinum/sdm/images/"}
 	#mkdir -p $imgdir/current
  	#mkdir -p $imgdir/latest
   	#mkdir -p $imgdir/archive
    	#chown -R $usrname:$usrname $imgdir
 	#download_latest_images
  	# Create custom.conf in installation directory
   	printf "# Custom configuration\n#--------------------\n\
imgdirectory = $imgdir\n\
wificountry = GB\n\
wifissid = TPL_Picluster\n\
wifipassword = 81zN3tLAN!WF\n" > $instdir/custom.conf
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
  	rm -rf $imgdir/latest/*.img
	# Download latest images and extract
	wget -P $imgdir/latest $url64lite
 	wget -P $imgdir/latest $url64desk
  	wget -P $imgdir/latest $url32lite
   	wget -P $imgdir/latest $url32desk
    	unxz $imgdir/latest/*.xz
     	read -p "Downloads for $verlatest to $imgdir/latest complete, press enter to return to menu" input
}

customize_image()
{
	# Select image from
 	# - latest or current
  	
 	#imgmod=$imgdir/latest/2024-07-04-raspios-bookworm-arm64-lite.img
  	imgmod=$imgdir/latest/2024-07-04-raspios-bookworm-arm64.img
  	# Set target filename + copy to current 
   	#imgout=$imgdir/current/2024-07-04_64lite.img
    	imgout=$imgdir/current/2024-07-04_64desk.img
	cp $imgmod $imgout
	# - current
 
  	# Set username/password
	read -p "Password for $usrname: " usrpass
	sdm --customize --plugin user:"adduser=$usrname|password=$usrpass" --plugin user:"deluser=pi" --plugin network:"wifissid=TPL_Picluster|wifipassword=81zN3tLAN!WF|wificountry=GB" --plugin L10n:host --plugin disables:piwiz --extend --expand-root --regen-ssh-host-keys --restart $imgout
}

burn_image()
{
	# Select image
 	#imgburn=$imgdir/current/2024-07-04_64lite.img
  	imgburn=$imgdir/current/2024-07-04_64desk.img
	# Create list for drive selection
 	# lsblk
 	drvtarget=sda
	sdm --burn /dev/$drvtarget --hostname pinode-5 --expand-root $imgburn
}

read_config
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


#read -p "Path to image directory (press enter for default = $usrpath/share$pinum/sdm/images/): " userdir
#imgdir=${userdir:="$usrpath/share$pinum/sdm/images/"}
#mkdir $imgdir

