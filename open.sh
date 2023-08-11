#!/bin/sh
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
echo ----- DISABLE IPV6 -----
uci set 'network.lan.ipv6=0'
uci set 'network.wan.ipv6=0'
uci set 'dhcp.lan.dhcpv6=disabled'
/etc/init.d/odhcpd disable
uci commit

uci -q delete dhcp.lan.dhcpv6
uci -q delete dhcp.lan.ra
uci commit dhcp
/etc/init.d/odhcpd restart

uci set network.lan.delegate="0"
uci commit network
/etc/init.d/network restart

/etc/init.d/odhcpd disable
/etc/init.d/odhcpd stop

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
echo ----- SET CLOUDFLARE WAN DNS -----
uci set network.wan.peerdns="0"
uci -q delete network.wan.dns
uci add_list network.wan.dns="1.1.1.1"
uci add_list network.wan.dns="1.0.0.1"
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
/etc/init.d/odhcpd restart
reboot
