# Install SDM
curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | bash

# Download latest images and extract
wget https://downloads.raspberrypi.org//raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-lite.img.xz
wget https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64.img.xz
unxz *.xz

