# Pull updates and return to working directory
cd /home/$usrname/.pisetup/rpi-nvme
git pull https://github.com/cms66/rpi-nvme
cd $OLDPWD
read -p "Finished setup update, press enter to return to menu" input
