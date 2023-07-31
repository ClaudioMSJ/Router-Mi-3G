#!/bin/sh 
 
 echo --------- UPDATE PACKAGES --------
#Update Packages
opkg update

sleep 5
echo
 echo --------- INICIAL -------- 
#Remove Wifi 
uci del wireless.default_radio0
uci del wireless.default_radio1
uci commit wireless

#Firewall
uci set firewall.cfg01e63d.flow_offloading='1'
uci set firewall.cfg01e63d.flow_offloading_hw='1'
uci commit firewall
 
# Step 1 
uci set 'network.lan.ipv6=0'
uci set 'network.wan.ipv6=0'
uci set 'dhcp.lan.dhcpv6=disabled'
/etc/init.d/odhcpd disable
uci commit
 
#Step 2 
uci -q delete dhcp.lan.dhcpv6
uci -q delete dhcp.lan.ra
uci commit dhcp
/etc/init.d/odhcpd restart
 
#Step 3 
uci set network.lan.delegate="0"
uci commit network
/etc/init.d/network restart
 
#Step 4 
/etc/init.d/odhcpd disable
/etc/init.d/odhcpd stop
 
#Step 5 
uci -q delete network.globals.ula_prefix
uci commit network
/etc/init.d/network restart

sleep 5
 echo
 echo --------- UNBOUND --------
#Replace Dnsmasq
opkg remove dnsmasq odhcpd-ipv6only
opkg install odhcpd
uci -q delete dhcp.@dnsmasq[0]
uci set dhcp.lan.dhcpv4="server"
uci set dhcp.odhcpd.maindhcp="1"
uci commit dhcp
/etc/init.d/odhcpd restart 
 
# Install packages
opkg install unbound-control unbound-daemon
uci set unbound.@unbound[0].add_local_fqdn="3"
uci set unbound.@unbound[0].add_wan_fqdn="1"
uci set unbound.@unbound[0].dhcp_link="odhcpd"
uci set unbound.@unbound[0].dhcp4_slaac6="1"
uci set unbound.@unbound[0].unbound_control="1"
 
# Configure DoT provider
uci set unbound.fwd_google.enabled="0"
uci set unbound.fwd_cloudflare.enabled="1"
uci set unbound.fwd_cloudflare.fallback="0"

uci commit unbound
/etc/init.d/unbound restart
uci commit unbound
/etc/init.d/unbound restart
uci set dhcp.odhcpd.leasetrigger="/usr/lib/unbound/odhcpd.sh"
uci commit dhcp
/etc/init.d/odhcpd restart


sleep 5
echo
 echo --------- ADBLOCK --------
# Install packages
opkg install adblock
 
# Provide web interface
opkg install luci-app-adblock

#List
uci del adblock.global.adb_sources
uci add_list adblock.global.adb_sources='adguard'
echo 'googleadservices.com' >> /etc/adblock/adblock.whitelist
 
# Backup the blocklists
uci set adblock.global.adb_backupdir="/etc/adblock"
 
# Save and apply
uci commit adblock
/etc/init.d/adblock restart
/etc/init.d/adblock reload

reboot
