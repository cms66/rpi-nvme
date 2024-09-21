# First boot - Base setup
# Assumes
# - rpi imager used to configure user/hostname
# sudo run this script as created user

# Install/update software
apt-get -y update
apt-get -y upgrade
# apt-get -y install
# Update firmware
rpi-eeprom-update -a
