#!/bin/bash

# Логирование действий
exec &> /var/log/change_ip_address.log

# Проверка наличия прав доступа
if [ "$EUID" -ne 0 ]; then
  echo "Этот скрипт должен быть запущен с правами суперпользователя"
  exit 1
fi

# Проверка передачи аргументов
if [ "$#" -ne 2 ]; then
  echo "Использование: $0 <название интерфейса> <новый IP-адрес>"
  exit 1
fi

interface=$1
new_ip=$2

# Проверка существования сетевого интерфейса
if ! ip link show $interface &> /dev/null; then
  echo "Сетевой интерфейс $interface не найден"
  exit 1
fi

# Изменение IP-адреса путем редактирования файла сетевой конфигурации
sed -i "/^address/s/.*/address $new_ip/" /etc/network/interfaces

if [ $? -eq 0 ]; then
  echo "IP-адрес интерфейса $interface успешно изменен на $new_ip"
else
  echo "Не удалось изменить IP-адрес интерфейса $interface"
fi

# Перезагрузка сетевого интерфейса
ifdown $interface && ifup $interface

# Вывод информации о текущей сетевой конфигурации
echo "Текущая сетевая конфигурация для интерфейса $interface:"
ip addr show $interface
