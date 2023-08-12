#!/bin/sh

sleep 5
echo
echo ----- TIMEZONE SÃO PAULO -----
uci del system.ntp.enabled
uci del system.ntp.enable_server
uci set system.cfg01e48a.zonename='America/Sao Paulo'
uci set system.cfg01e48a.timezone='<-03>3'
uci set system.cfg01e48a.log_proto='udp'
uci set system.cfg01e48a.conloglevel='8'
uci set system.cfg01e48a.cronloglevel='5'
uci commit system

sleep 5
echo
echo ----- TASK REBOOT -----
/etc/init.d/cron enable
echo '00 06 * * * reboot' >> /etc/crontabs/root
/etc/init.d/cron start

echo ----- UPDATE -----
opkg update

sleep 5
echo
echo ----- INSTALL ADGUARD HOME -----
opkg install sudo ca-certificates ca-bundle curl wget wget-ssl tar unzip bind-tools
curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -c edge
echo 'Sucess Install AdGuardHome.'

sleep 5
echo
echo ----- ENABLE FIREWALL HW -----
uci set firewall.cfg01e63d.flow_offloading='1'
uci set firewall.cfg01e63d.flow_offloading_hw='1'
uci commit firewall

sleep 5
echo
echo ----- DISABLE IPV6 -----
uci set 'network.lan.ipv6=0'
uci set 'network.wan.ipv6=0'
uci set 'dhcp.lan.dhcpv6=disabled'
uci commit

uci -q delete dhcp.lan.dhcpv6
uci -q delete dhcp.lan.ra
uci commit dhcp

uci set network.lan.delegate="0"
uci commit network

uci -q delete network.globals.ula_prefix
uci commit network

sleep 5
echo
echo ----- REMOVE DNSMASQ -----
opkg remove dnsmasq odhcpd-ipv6only
opkg install odhcpd
uci -q delete dhcp.@dnsmasq[0]
uci set dhcp.lan.dhcpv4="server"
uci set dhcp.odhcpd.maindhcp="1"
uci commit dhcp

sleep 5
echo
echo ----- SET CLOUDFLARE WAN DNS -----
uci set network.wan.peerdns="0"
uci -q delete network.wan.dns
uci add_list network.wan.dns="1.1.1.1"
uci add_list network.wan.dns="1.0.0.1"
uci commit network
reboot
