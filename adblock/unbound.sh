#!/bin/sh

# Desabilitar IPV6
uci set 'network.lan.ipv6=0'
uci set 'network.wan.ipv6=0'
uci set 'dhcp.lan.dhcpv6=disabled'
uci -q delete dhcp.lan.dhcpv6
uci -q delete dhcp.lan.ra
uci set network.lan.delegate="0"
uci -q delete network.globals.ula_prefix

# Desabilitar Led Azul
uci add system led
uci set system.@led[-1].name='Blue'
uci set system.@led[-1].sysfs='blue:status'
uci set system.@led[-1].trigger='none'
uci set system.@led[-1].default='0'

# Horário
uci set system.@system[0].zonename='America/Sao Paulo'
uci set system.@system[0].timezone='<-03>3'

# Ativar Hardware e Software Offloading
uci set firewall.@defaults[0].flow_offloading='1'
uci set firewall.@defaults[0].flow_offloading_hw='1'

# Desabilitar Allow-Ping
uci set firewall.@rule[1].enabled=0

# Desabilitar DNS ISP
uci set network.wan.peerdns='0'
uci add_list network.wan.dns='127.0.0.1'

# Unbound Config
sed -i "s/option listen_port '53'/option listen_port '5353'/g" /etc/config/unbound
sed -i "s/option add_local_fqdn '2'/option add_local_fqdn '0'/g" /etc/config/unbound
uci set dhcp.@dnsmasq[0].noresolv="1"
uci set dhcp.@dnsmasq[0].cachesize='0'
uci -q delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server="127.0.0.1#5353"
uci del system.ntp.server
uci add_list system.ntp.server='194.177.4.1'
uci add_list system.ntp.server='213.222.217.11'
uci add_list system.ntp.server='80.50.102.114'
uci add_list system.ntp.server='193.219.28.60'

# Ao Iniciar
rm /etc/rc.local
echo 'sleep 30 && sh /root/adblock.sh
sleep 300 && echo 3 > /proc/sys/vm/drop_caches
exit 0' >> /etc/rc.local

# Script Adblock Start
echo '#!/bin/bash
while ! ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1; do
    echo "Waiting for 8.8.8.8 - network interface might be down..."
done
wget -q https://raw.githubusercontent.com/sjhgvr/oisd/refs/heads/main/dnsmasq_small.txt -O /etc/dnsmasq.conf
uci commit dhcp
/etc/init.d/dnsmasq restart ' >> /root/adblock.sh
chmod +x /root/adblock.sh

# Drops Cache Auto
echo '0 6 * * * echo 3 > /proc/sys/vm/drop_caches' >> /etc/crontabs/root
echo '0 5 * * * sh /root/adblock.sh' >> /etc/crontabs/root
service cron restart

# Salvar Configs
uci commit

reboot
