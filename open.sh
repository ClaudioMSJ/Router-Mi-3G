#!/bin/sh

echo ----- UPDATE -----
opkg update

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
opkg remove dnsmasq odhcpd odhcpd-ipv6only

sleep 5
echo
echo ----- ENABLE FIREWALL HW -----
uci set firewall.cfg01e63d.flow_offloading='1'
uci set firewall.cfg01e63d.flow_offloading_hw='1'
uci commit firewall

sleep 5
echo
echo ----- INSTALL ADGUARD HOME -----
opkg install curl
curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v
echo 'Sucess Install AdGuardHome.'

sleep 5
echo
echo ----- SET CLOUDFLARE WAN DNS -----
uci set network.wan.peerdns="0"
uci -q delete network.wan.dns
uci add_list network.wan.dns="1.1.1.1"
uci add_list network.wan.dns="1.0.0.1"
uci commit network
