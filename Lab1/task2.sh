function set_static_ip() {
  interface=$(ip -o -4 route show to default | awk '{print $5}')
  
  sudo ip addr flush dev $interface
  sudo ip addr add 10.100.0.2/24 dev $interface
  sudo ip route add default via 10.100.0.1
  echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
  echo "Static configuration installed."
}
