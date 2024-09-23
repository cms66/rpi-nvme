# First boot - Base setup
# Assumes
# - rpi imager or sdm used to configure user/hostname
# sudo run this script as created user

usrname=$(logname)
piname=$(hostname)
localnet=$(ip route | awk '/proto/ && !/default/ {print $1}')
repo="rpi-nvme"

# Install/update software
apt-get -y update
apt-get -y upgrade
apt-get -y install python3-dev gcc g++ gfortran libraspberrypi-dev libomp-dev git-core build-essential cmake pkg-config make screen htop stress zip nfs-common fail2ban ufw ntpdate

# Git setup
mkdir /home/$usrname/.pisetup
cd /home/$usrname/.pisetup
git clone https://github.com/cms66/$repo.git
chown -R $usrname:$usrname /home/$usrname/.pisetup

# Add bash alias for setup and test menu
echo "alias mysetup=\"sudo sh ~/.pisetup/$repo/setup_menu.sh\"" >> /home/$usrname/.bashrc
echo "alias mytest=\"sudo sh ~/.pisetup/$repo/test_menu.sh\"" >> /home/$usrname/.bashrc

# - Create python Virtual Environment (with access to system level packages) and bash alias for activation
python -m venv --system-site-packages /home/$usrname/.venv
echo "alias myvp=\"source ~/.venv/bin/activate\"" >> /home/$usrname/.bashrc
chown -R $usrname:$usrname /home/$usrname/.venv

# create local folder structure for created user with code examples
tar -xvzf /home/$usrname/.pisetup/$repo/local.tgz -C /home/$usrname
chown -R $usrname:$usrname /home/$usrname/local/

# Configure fail2ban
cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Configure firewall (ufw)
# Allow SSH from local subnet only, unless remote access needed
read -p "Allow remote (outside home network) ssh access (y/n)?" input
if [ X$input = X"n" ]
then
	ufw allow from $localnet to any port ssh
else
	ufw allow ssh
fi
ufw logging on
ufw enable

# Networking
echo "127.0.0.1   $piname.local $piname" >> /etc/hosts
localip=$(hostname -I | awk '{print $1}')
echo "$localip   $piname.local $piname" >> /etc/hosts
sed -i "s/rootwait/rootwait ipv6.disable=1/g" /boot/firmware/cmdline.txt

# Disable root SSH login
sed -i 's/#PermitRootLogin\ prohibit-password/PermitRootLogin\ no/g' /etc/ssh/sshd_config

# Set default shell to bash
echo "dash dash/sh boolean false" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Update firmware
#rpi-eeprom-update -a

# Reboot or Poweroff (if static IP setup needed on router)
read -p "Finished base setup, press p to poweroff (if setting a static IP on router) or any other key to reboot, then login as $usrname: " input
if [ X$input = X"p" ]
then
	poweroff
else
	reboot
fi
