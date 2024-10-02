clear
printf "System summary \n--------------\n"
printf "Model: $pimodel \n"
printf "Revision: $pirev \n"
printf "Architecture: $osarch \n"
printf "Firmware: $(rpi-eeprom-update) \n"
printf "\nMemory: \n$pimem \n"
printf "\nStorage: $(lsblk) \n"
printf "Firewall "
ufw status
read -p "Press enter to return to menu" input
