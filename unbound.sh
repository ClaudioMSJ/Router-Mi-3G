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
uci -q delete network.wan.dns
uci add_list network.wan.dns='127.0.0.1'

# Dnsmasq Disable
uci set dhcp.@dnsmasq[0].port='0'

# Unbound Configs
uci set unbound.@unbound[0].enabled='1'
uci set unbound.@unbound[0].listen_port='53'
uci set unbound.@unbound[0].validator='1'
uci set unbound.@unbound[0].query_minimize='1'
while uci -q del unbound.@zone[0]; do :; done
uci add unbound zone
uci set unbound.@zone[-1].enabled='1'
uci set unbound.@zone[-1].zone_type='forward_zone'
uci add_list unbound.@zone[-1].zone_name='.'
uci set unbound.@zone[-1].tls_upstream='1'
uci set unbound.@zone[-1].tls_index='cloudflare-dns.com'
uci add_list unbound.@zone[-1].server='1.1.1.1'
uci add_list unbound.@zone[-1].server='1.0.0.1'

# AdBlock Configs
uci set adblock.global.adb_enabled='1'
uci set adblock.global.adb_dns='unbound'
uci delete adblock.global.adb_feed
uci add_list adblock.global.adb_feed='hagezi'
uci add_list adblock.global.adb_hag_feed='pro.mini-onlydomains.txt'
uci set adblock.global.adb_trigger='wan'

# Firewall DNS
uci add firewall redirect
uci set firewall.@redirect[-1].name='Force DNS to Router (IPv4)'
uci set firewall.@redirect[-1].src='lan'
uci set firewall.@redirect[-1].src_dport='53'
uci set firewall.@redirect[-1].dest_port='53'
uci set firewall.@redirect[-1].dest='lan'
uci set firewall.@redirect[-1].target='DNAT'
uci set firewall.@redirect[-1].proto='tcp udp'

# Drops Cache Auto
echo '0 6 * * * echo 3 > /proc/sys/vm/drop_caches' >> /etc/crontabs/root
service cron restart

# Ao Iniciar
rm /etc/rc.local
echo 'sleep 300 && echo 3 > /proc/sys/vm/drop_caches
exit 0' >> /etc/rc.local

# Salvar Configs
uci commit

reboot
