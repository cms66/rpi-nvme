clear
#printf "System summary - $(hostname))\n--------------\n"
my_string="System summary ($(hostname))"
echo $my_string;printf -- '=%.0s' $(seq 1 ${#my_string})
printf "Model: $pimodel \n"
printf "Revision: $pirev \n"
printf "Architecture: $osarch \n"
printf "Firmware: $(rpi-eeprom-update) \n"
printf "\nMemory:\n$pimem \n"
printf "\nStorage:\n$(lsblk) \n"
printf "Firewall "
ufw status
read -p "Press enter to return to menu" input
