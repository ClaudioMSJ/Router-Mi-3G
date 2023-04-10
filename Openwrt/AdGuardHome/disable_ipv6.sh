#!/bin/sh

# Disable IPV6
uci set 'network.lan.ipv6=0'
uci set 'network.wan.ipv6=0'
uci set 'dhcp.lan.dhcpv6=disabled'
/etc/init.d/odhcpd disable
uci commit

# Disable RA and DHCPv6
uci -q delete dhcp.lan.dhcpv6
uci -q delete dhcp.lan.ra
uci commit dhcp
/etc/init.d/odhcpd restart

# Disable the LAN delegation
uci set network.lan.delegate="0"
uci commit network
/etc/init.d/network restart

# disable odhcpd
/etc/init.d/odhcpd disable
/etc/init.d/odhcpd stop

#Delete IPv6 ULA Prefix
uci -q delete network.globals.ula_prefix
uci commit network
/etc/init.d/network restart
