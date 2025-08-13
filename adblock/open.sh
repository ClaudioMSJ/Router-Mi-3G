#!/bin/sh

# Desabilitar IPV6
uci set network.lan.ipv6='0'
uci set network.wan.ipv6='0'
uci set network.wan6=' '
uci set dhcp.lan.dhcpv6='disabled'
uci set dhcp.lan.ra='disabled'
uci set dhcp.lan.ndp='disabled'
uci set firewall.@defaults[0].disable_ipv6='1'

# Desabilitar Led Azul
uci add system led
uci set system.@led[-1].name='Blue'
uci set system.@led[-1].sysfs='blue:status'
uci set system.@led[-1].trigger='none'
uci set system.@led[-1].default='0'

# Horário e Log
uci set system.@system[0].zonename='America/Sao Paulo'
uci set system.@system[0].timezone='<-03>3'
uci set system.@system[0].log_size='16'
uci set system.@system[0].log_rotated='3'

# Ativar Hardware e Software Offloading
uci set firewall.@defaults[0].flow_offloading='1'
uci set firewall.@defaults[0].flow_offloading_hw='1'

# Desabilitar Allow-Ping
uci set firewall.@rule[1].enabled=0

# Desabilitar DNS ISP
uci set network.wan.peerdns='0'
uci add_list network.wan.dns='127.0.0.1'

# Configura https-dns-proxy para Cloudflare DoH
while uci -q delete https-dns-proxy.@https-dns-proxy[0]; do :; done
uci set https-dns-proxy.dns="https-dns-proxy"
uci set https-dns-proxy.dns.bootstrap_dns="1.1.1.1,1.0.0.1"
uci set https-dns-proxy.dns.resolver_url="https://cloudflare-dns.com/dns-query"
uci set https-dns-proxy.dns.listen_addr="127.0.0.1"
uci set https-dns-proxy.dns.listen_port="5053"
uci set https-dns-proxy.@https-dns-proxy[-1].force_dns='1'
uci set dhcp.@dnsmasq[0].noresolv='1'
uci -q delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server='127.0.0.1#5053'

# Dnsmasq Config
uci set dhcp.@dnsmasq[0].cachelocal='1'        # Mantém cache local
uci set dhcp.@dnsmasq[0].cachesize='1000'      # Aumenta cache
uci set dhcp.@dnsmasq[0].dnsforwardmax='500'   # Mais consultas simultâneas
uci set dhcp.@dnsmasq[0].allservers='1'        # Usa todos DNS em paralelo
uci set dhcp.@dnsmasq[0].localservice='1'      # Restringe consultas ao LAN
uci set dhcp.@dnsmasq[0].quietdhcp='1'         # Menos log DHCP
uci set dhcp.@dnsmasq[0].quietdhcp6='1'        # Menos log DHCPv6
uci set dhcp.@dnsmasq[0].localttl='3600'       # TTL local maior
uci set dhcp.@dnsmasq[0].filteraaaa='1'
uci set dhcp.@dnsmasq[0].dhcpv6='disabled'
uci set dhcp.lan.ra='disabled'
uci set dhcp.lan.dhcpv6='disabled'

# Bloqueio DNS direto (porta 53)
uci add firewall rule
uci set firewall.@rule[-1].name='Block-DNS-Direct'
uci set firewall.@rule[-1].src='lan'
uci set firewall.@rule[-1].dest='wan'
uci set firewall.@rule[-1].proto='tcp udp'
uci set firewall.@rule[-1].dest_port='53'
uci set firewall.@rule[-1].target='REJECT'

# Ao Iniciar
rm /etc/rc.local
echo 'sleep 30 && sync && sh /root/adblock.sh
sleep 300 && echo 3 > /proc/sys/vm/drop_caches
exit 0' >> /etc/rc.local

# Script Adblock Start
echo '#!/bin/bash
while ! ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1; do
    echo "Waiting for 8.8.8.8 - network interface might be down..."
done
wget -O - https://raw.githubusercontent.com/sjhgvr/oisd/refs/heads/main/dnsmasq_small.txt | \
grep -v '^#' | sort -u | \
sed 's/^/address=\//' | sed 's/$/\/0.0.0.0/' > /etc/dnsmasq.conf
/etc/init.d/dnsmasq restart ' >> /root/adblock.sh
chmod +x /root/adblock.sh

# Drops Cache Auto
echo '0 6 * * * sync && echo 3 > /proc/sys/vm/drop_caches' >> /etc/crontabs/root
echo '0 5 * * * sh /root/adblock.sh' >> /etc/crontabs/root
service cron restart

# Salvar Configs
uci commit

reboot
