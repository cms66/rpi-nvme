clear
#printf "System summary - $(hostname))\n--------------\n"
strtitle="System summary ($(hostname))"
echo $strtitle;printf -- '=%.0s' $(seq 1 ${#strtitle})
printf "\nRepo: $repo \n"
printf "\nRepo - script: $reposcr \n"
printf "\nModel: $pimodel \n"
printf "Revision: $pirev \n"
printf "Architecture: $osarch \n"
printf "Firmware: $(rpi-eeprom-update) \n"
printf "\nMemory:\n$pimem \n"
printf "\nStorage:\n$(lsblk) \n"
printf "Firewall "
ufw status
read -p "Press enter to return to menu" input
