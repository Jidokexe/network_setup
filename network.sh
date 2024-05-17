#!/bin/bash

# Логирование действий
LOG_FILE="/var/log/change_ip_address.log"
exec > >(tee -a ${LOG_FILE} )
exec 2>&1

# Проверка наличия необходимых прав доступа
if [ "$(id -u)" -ne 0 ]; then
    echo "Ошибка: Необходимы права суперпользователя для выполнения скрипта." >&2
    exit 1
fi

# Проверка передачи аргументов
if [ "$#" -ne 2 ]; then
    echo "Использование: $0 <interface> <new_ip_address>"
    exit 1
fi

interface=$1
new_ip=$2

# Проверка существования сетевого интерфейса
if ! ip a show dev $interface > /dev/null 2>&1; then
    echo "Ошибка: Сетевой интерфейс $interface не найден."
    exit 1
fi

# Изменение IP-адреса путем редактирования файла сетевой конфигурации
sed -i "/^address/s/.*/address $new_ip/" /etc/sysconfig/network-scripts/ifcfg-enp1s0

if [ $? -eq 0 ]; then
    echo "Успешно изменили IP-адрес на $new_ip для интерфейса $interface."
    # Вывод информации о текущей сетевой конфигурации
    ip a show dev $interface
else
    echo "Ошибка: не удалось изменить IP-адрес для интерфейса $interface."
    exit 1
fi

# Перезагрузка сетевого интерфейса
ifdown $interface && ifup $interface

# Вывод информации о текущей сетевой конфигурации
echo "Текущая сетевая конфигурация для интерфейса $interface:"
ip addr show $interface
