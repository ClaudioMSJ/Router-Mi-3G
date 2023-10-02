#!/bin/sh

opkg update

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

opkg remove dnsmasq odhcpd-ipv6only
opkg install odhcpd
uci -q delete dhcp.@dnsmasq[0]
uci set dhcp.lan.dhcpv4="server"
uci set dhcp.odhcpd.maindhcp="1"
uci commit dhcp
/etc/init.d/odhcpd restart

opkg install unbound-control unbound-daemon
uci set unbound.@unbound[0].add_local_fqdn="3"
uci set unbound.@unbound[0].add_wan_fqdn="1"
uci set unbound.@unbound[0].dhcp_link="odhcpd"
uci set unbound.@unbound[0].unbound_control="1"
uci set unbound.fwd_google.enabled="0"
uci set unbound.fwd_cloudflare.enabled="1"
uci set unbound.fwd_cloudflare.fallback="0"
uci set unbound.@unbound[0].validator="1"
uci commit unbound
/etc/init.d/unbound restart
uci set dhcp.odhcpd.leasetrigger="/usr/lib/unbound/odhcpd.sh"
uci commit dhcp
/etc/init.d/odhcpd restart

opkg install luci-app-adblock
uci set adblock.global.adb_enabled="1" 
uci set adblock.global.adb_backupdir="/etc/adblock"
echo "googleadservices.com" > /etc/adblock/adblock.whitelist
uci commit adblock
/etc/init.d/adblock restart

uci set firewall.cfg01e63d.flow_offloading='1'
uci set firewall.cfg01e63d.flow_offloading_hw='1'
uci commit firewall

opkg list-upgradable | cut -f 1 -d ' ' | xargs opkg install

reboot
