# Install SDM
curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | bash

# Download latest images and extract
read -p "Path to directory for images (press enter for default = $usrpath/share$pinum/sdm/): " userdir
imgdir=${userdir:="$usrpath/share$pinum/sdm/"}
mkdir $imgdir
wget -P $imgdir https://downloads.raspberrypi.org//raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-lite.img.xz
wget -P $imgdir https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64.img.xz
wget -P $imgdir https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2024-07-04/2024-07-04-raspios-bookworm-armhf-lite.img.xz
unxz *.xz

