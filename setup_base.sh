# First boot - Base setup
# Assumes
# - rpi imager or sdm used to configure user/hostname
# sudo run this script as created user
# TODO
# - Get git repo/branch from curl request url
# - Test update firmware (current Pi 4/5 up to date)
# - Test setup on Desktop

set -e

# Set default shell to bash
dpkg-divert --remove --no-rename /usr/share/man/man1/sh.1.gz
dpkg-divert --remove --no-rename /bin/sh
ln -sf bash.1.gz /usr/share/man/man1/sh.1.gz
ln -sf bash /bin/sh
dpkg-divert --add --local --no-rename /usr/share/man/man1/sh.1.gz
dpkg-divert --add --local --no-rename /bin/sh

# Error handler
handle_error()
{
	echo "Error: $(caller) : ${BASH_COMMAND}"
}

# Set the error handler to be called when an error occurs
trap handle_error ERR

usrname=$(logname) # Script runs as root
piname=$(hostname)
localnet=$(ip route | awk '/proto/ && !/default/ {print $1}')
repo="rpi-nvme"
repobranch="main"
pimodelnum=$(cat /sys/firmware/devicetree/base/model | cut -d " " -f 3)

# Install/update software
apt-get -y update
apt-get -y upgrade
apt-get -y install python3-dev gcc g++ gfortran libraspberrypi-dev libomp-dev git-core build-essential cmake pkg-config make screen htop stress zip nfs-common fail2ban ufw ntpdate

# Git setup
mkdir /home/$usrname/.pisetup
cd /home/$usrname/.pisetup
git clone https://github.com/cms66/$repo.git
printf "# Setup - Custom configuration\n# --------------------\n\
repo = $repo\n\
repobranch = $repobranch\n" > /home/$usrname/.pisetup/custom.conf
chown -R $usrname:$usrname /home/$usrname/.pisetup

# Add bash alias for setup and test menu
echo "alias mysetup=\"sudo bash ~/.pisetup/$repo/setup_menu.sh\"" >> /home/$usrname/.bashrc
echo "alias mytest=\"sudo bash ~/.pisetup/$repo/test_menu.sh\"" >> /home/$usrname/.bashrc

# - Create python Virtual Environment (with access to system level packages) and bash alias for activation
python -m venv --system-site-packages /home/$usrname/.venv
echo "alias myvp=\"source ~/.venv/bin/activate\"" >> /home/$usrname/.bashrc
echo "alias dvp=\"deactivate\"" >> /home/$usrname/.bashrc
chown -R $usrname:$usrname /home/$usrname/.venv

# create local folder structure for created user with code examples
tar -xvzf /home/$usrname/.pisetup/$repo/local.tgz -C /home/$usrname
chown -R $usrname:$usrname /home/$usrname/local/

# Configure fail2ban
cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Configure firewall (ufw)
# Allow SSH from local subnet only, unless remote access needed
read -rp "Allow remote ssh acces (y/n): " inp </dev/tty

if [ X$inp = X"y" ] # TODO - not case insensitive
then # Remote
 	yes | sudo ufw allow ssh
else # Local
	yes | sudo ufw allow from $localnet to any port ssh
fi
yes | sudo ufw logging on
yes | sudo ufw enable

# Networking
echo "127.0.0.1   $piname.local $piname" >> /etc/hosts
localip=$(hostname -I | awk '{print $1}')
echo "$localip   $piname.local $piname" >> /etc/hosts
sed -i "s/rootwait/rootwait ipv6.disable=1/g" /boot/firmware/cmdline.txt

# Disable root SSH login
sed -i 's/#PermitRootLogin\ prohibit-password/PermitRootLogin\ no/g' /etc/ssh/sshd_config

# Update firmware - Only applies to model 4/5
if [ $pimodelnum = "4" ] || [ $pimodelnum = "5" ]; then # Model has firmware
	printf "Model has firmware\n"
	updfirm=$(sudo rpi-eeprom-update | grep BOOTLOADER | cut -d ":" -f 2 | tr -d '[:blank:]') # Check for updates
	printf "Update status: $updfirm\n"
 	if ! [ $updfirm = "uptodate" ]; then # Update available - TODO - too many args
 		printf "Update available\n"
  		read -p "Firmware update available, press y to update now or any other key to continue: " input </dev/tty
  		printf "Update selected\n"
    	if [ X$input = X"y" ]; then # Apply firmware update
    		printf "Update firmware\n"
			# rpi-eeprom-update -a
   		fi
     else
     	printf "Firmware is up to date\n"
     fi
else
	printf "No firmware\n"
fi

# Reboot or Poweroff (if static IP setup needed on router)
read -rp "Finished base setup press p to poweroff or any other key to reboot: " inp </dev/tty

if [ X$inp = X"p" ]
then
	poweroff
else
	reboot
fi
