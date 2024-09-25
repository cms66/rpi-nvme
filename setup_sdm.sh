# SDM Drive Imager
# Latest images
url64lite=https://downloads.raspberrypi.org//raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-lite.img.xz
url64desk=https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64.img.xz
url32lite=https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2024-07-04/2024-07-04-raspios-bookworm-armhf-lite.img.xz
url32desk=https://downloads.raspberrypi.com/raspios_armhf/images/raspios_armhf-2024-07-04/2024-07-04-raspios-bookworm-armhf.img.xz

show_sdm_menu()
{
	clear
	printf "SDM Drive Imager setup menu \n----------\n\
 1) Install - local \n\
 2) Install - server \n\
 3)  \n"
}

install_local()
{

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

show_sdm_menu
read -p "Select option or x to exit to main menu: " n
while [ $n != "x" ]; do
	case $n in
		1) install_local;;
		2) install_server;;
		3) install_client;;
  		*) read -p "invalid option - press enter to continue" errkey;;
	esac
	show_sdm_menu
	read -p "Select option or x to exit to main menu: " n
done

# Install SDM
curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | bash
# Download latest images and extract
read -p "Path to install directory (press enter for default = $usrpath/share$pinum/sdm/): " userdir
imgdir=${userdir:="$usrpath/share$pinum/sdm/"}
mkdir $imgdir
wget -P $imgdir https://downloads.raspberrypi.org//raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-lite.img.xz
wget -P $imgdir https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64.img.xz
wget -P $imgdir https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2024-07-04/2024-07-04-raspios-bookworm-armhf-lite.img.xz
unxz $imgdir/*.xz

