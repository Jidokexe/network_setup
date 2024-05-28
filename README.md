.Программа для изменения ip адреса для выбранного сетевого интерфейса. Программа также логирует все действия и проверяет выполнение поэтапно.

#logging
LOG_FILE="/var/log/change_ip_address.log"
exec > >(tee -a ${LOG_FILE} )
exec 2>&1

#Check of user rights
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: need root." >&2
    exit 1
fi

#Check of arguments transfer
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <interface> <new_ip_address>"
    exit 1
fi

interface=$1
new_ip=$2

#Check if network enterface exists
if ! ip a show dev $interface > /dev/null 2>&1; then
    echo "Error: network interface $interface not found."
    exit 1
fi

#Changing ip with sed editor
sed -i "/^address/s/.*/address $new_ip/" /etc/sysconfig/network-scripts/ifcfg-enp1s0

if [ $? -eq 0 ]; then
    echo "Successeful changing of ip address with $new_ip on interface $interface."

#Current netconf state
    ip a show dev $interface
else
    echo "Error: cannot change ip address on interface $interface."
    exit 1
fi

#Network interface reboot
ifdown $interface && ifup $interface

#Print current state of netconf for network interface 
echo "Current state of netconf for network interface $interface:"
ip addr show $interface
