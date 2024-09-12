#!/bin/bash

if [ "$(id -u)" -ne "0" ]; then
  echo "Скрипт должен быть запущен от имени суперпользователя."
  exit 1
fi

get_network_info() {
  echo "\n"
  echo -----------------

  echo "Информация о сетевой карте:"

  echo -n "Модель сетевой карты: "
  ethtool -i eth0 | grep "driver:" | awk '{print $2}'

  echo -n "Канальная скорость и режим работы: "
  ethtool eth0 | awk '/Speed:/ {print $2}'
  ethtool eth0 | awk '/Duplex:/ {print $2}'

  echo -n "Наличие физического подключения (линка): "
  ethtool eth0 | awk '/Link detected:/ {print $3}'

  echo -n "MAC адрес: "
  ip link show eth0 | awk '/link\/ether/ {print $2}'
  
  echo -----------------
  echo "\n"
}

get_ipv4_info() {
  echo "Информация о текущей конфигурации IPv4:"

  IP_ADDR=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1)
  MASK=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f2)
  GATEWAY=$(ip route show | awk '/default/ {print $3}')
  DNS=$(grep "nameserver" /etc/resolv.conf | awk '{print $2}' | paste -sd ", ")

  echo "\n"
  echo -----------------
  echo -n "IP адрес: "
  echo $IP_ADDR
  echo -n "Маска подсети: "
  echo $MASK
  echo -n "Шлюз: "
  echo $GATEWAY
  echo -n "DNS: "
  echo $DNS
  echo -----------------
  echo "\n"
}

clear_ip_addresses() {
  echo "Удаление старых IP-адресов с интерфейса eth0"
  IP_ADDRESSES=$(ip addr show eth0 | awk '/inet / {print $2}')
  for IP in $IP_ADDRESSES; do
    ip addr del $IP dev eth0
  done
}

configure_static() {
  echo "Настройка сетевого интерфейса по сценарию #1"
  clear_ip_addresses
  ip addr add 10.100.0.2/24 dev eth0
  ip route add default via 10.100.0.1
  echo "nameserver 8.8.8.8" > /etc/resolv.conf
}

configure_dhcp() {
  echo "Настройка сетевого интерфейса по сценарию #2"
  clear_ip_addresses
  dhclient eth0
}


while true; do
    echo "1. Узнать информацию о сетевой карте"
    echo "2. Получить информацию о текущей конфигурации IPv4"
    echo "3. Настроить сетевой интерфейс по сценарию #1 (статическая адресация)"
    echo "4. Настроить сетевой интерфейс по сценарию #2 (динамическая адресация)"
    echo "5. Закрыть скрипт"

    read -p "Введите номер действия: " choice

    case $choice in
        1) get_network_info ;;
        2) get_ipv4_info ;;
        3) configure_static ;;
        4) configure_dhcp ;;
        5) exit ;;
        *) echo "Неправильный выбор. Попробуйте еще раз." ;;
    esac
done
