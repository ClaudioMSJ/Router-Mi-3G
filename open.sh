#!/bin/sh

# OpenWrt After Install

echo ----- UPDATE ALL PACKAGES -----
opkg update
opkg list-upgradable | cut -f 1 -d ' ' | xargs opkg install

sleep 5
echo
echo ----- DISABLE IPV6 -----
uci -q delete network.globals.ula_prefix
uci commit network
/etc/init.d/network restart

sleep 5
echo
echo ----- ENABLE FIREWALL HW -----
uci set firewall.cfg01e63d.flow_offloading='1'
uci set firewall.cfg01e63d.flow_offloading_hw='1'
uci commit firewall

sleep 5
echo
echo ----- INSTALL ADGUARD HOME -----
opkg remove dnsmasq odhcpd-ipv6only
rm /etc/config/dhcp
opkg install sudo ca-certificates ca-bundle curl wget wget-ssl tar unzip bind-tools
curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -c edge
echo 'Sucess Install AdGuardHome.'

sleep 5
echo
echo ----- SET CLOUDFLARE WAN DNS -----
uci set network.wan.peerdns="0"
uci -q delete network.wan.dns
uci add_list network.wan.dns="1.1.1.1"
uci add_list network.wan.dns="1.0.0.1"
uci commit network
