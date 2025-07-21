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
# uci set network.wan.dns='1.1.1.1 1.0.0.1'

# DOH Configs
uci set dhcp.@dnsmasq[0].noresolv='1'
uci set dhcp.@dnsmasq[0].strictorder='1'
uci -q delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server='127.0.0.1#5053'

uci -q delete https-dns-proxy.@https-dns-proxy[0]
uci set https-dns-proxy.cloudflare_doh="https-dns-proxy"
uci set https-dns-proxy.cloudflare_doh.listen_addr="127.0.0.1"
uci set https-dns-proxy.cloudflare_doh.listen_port="5053"
uci add_list https-dns-proxy.cloudflare_doh.resolver_url="https://cloudflare-dns.com/dns-query"
uci add_list https-dns-proxy.cloudflare_doh.resolver_url="https://1.1.1.1/dns-query"
uci set https-dns-proxy.cloudflare_doh.bootstrap_dns="1.1.1.1,1.0.0.1"
uci set https-dns-proxy.cloudflare_doh.force_dns='1'
uci set https-dns-proxy.cloudflare_doh.enabled='1'

#Adblock Lean
uclient-fetch https://raw.githubusercontent.com/lynxthecat/adblock-lean/master/abl-install.sh -O /tmp/abl-install.sh
sh /tmp/abl-install.sh -v release

# Ao Iniciar
rm /etc/rc.local
echo 'sleep 30 && sh /root/adblock.sh
exit 0' >> /etc/rc.local

echo '#!/bin/bash
while ! ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1; do
    echo "Waiting for 8.8.8.8 - network interface might be down..."
    sleep 10
done
service adblock-lean restart
echo "Adblock Service Manually Reloaded"' >> /root/adblock.sh
chmod +x /root/adblock.sh

# Salvar Configs
uci commit

reboot
