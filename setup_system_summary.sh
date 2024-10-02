clear
printf "System summary ($(hostname))\n--------------\n"
printf "Model: $pimodel \n"
printf "Revision: $pirev \n"
printf "Architecture: $osarch \n"
printf "Firmware: $(rpi-eeprom-update) \n"
printf "\nMemory:\n$pimem \n"
printf "\nStorage:\n$(lsblk) \n"
printf "Firewall "
ufw status
read -p "Press enter to return to menu" input
