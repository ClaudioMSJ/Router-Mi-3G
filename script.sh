#!/bin/sh

echo ----- UPDATE ALL PACKAGES -----
#Update All Packages
opkg update
opkg list-upgradable | cut -f 1 -d ' ' | xargs opkg install

sleep 5
echo
echo ----- DISABLE IPV6 -----
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

sleep 5
echo
echo ----- ENABLE FIREWALL HW -----
#Firewall
uci set firewall.cfg01e63d.flow_offloading='1'
uci set firewall.cfg01e63d.flow_offloading_hw='1'
uci commit firewall

sleep 5
echo
echo ----- REMOVE WIFI -----
#Remove Wifi 
uci del wireless.default_radio0
uci del wireless.default_radio1
uci commit wireless

sleep 5
echo
echo ----- INSTALL ADGUARD HOME -----
#!/bin/sh
# Switch to Adguard setup
# Grab packages for AGH and updates.
opkg install sudo ca-certificates ca-bundle curl wget wget-ssl tar unzip bind-tools
curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v
NET_ADDR=$(/sbin/ip -o -4 addr list br-lan | awk 'NR==1{ split($4, ip_addr, "/"); print ip_addr[1] }')
NET_ADDR6=$(/sbin/ip -o -6 addr list br-lan scope global | awk 'NR==1{ split($4, ip_addr, "/"); print ip_addr[1] }')
 echo "Router IPv4 : ""${NET_ADDR}"
echo "Router IPv6 : ""${NET_ADDR6}"
uci set dhcp.@dnsmasq[0].noresolv='0'
uci set dhcp.@dnsmasq[0].cachesize='1000'
uci set dhcp.@dnsmasq[0].rebind_protection='0'
uci set dhcp.@dnsmasq[0].port='54'
uci -q delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server="${NET_ADDR}"
uci set dhcp.lan.leasetime='24h'
uci -q delete dhcp.lan.dhcp_option
uci -q delete dhcp.lan.dns
uci add_list dhcp.lan.dhcp_option='6,'"${NET_ADDR}" 
uci add_list dhcp.lan.dhcp_option='3,'"${NET_ADDR}"
for OUTPUT in $(ip -o -6 addr list br-lan scope global | awk '{ split($4, ip_addr, "/"); print ip_addr[1] }')
do
	echo "Adding $OUTPUT to IPV6 DNS"
	uci add_list dhcp.lan.dns=$OUTPUT
done
uci commit dhcp
/etc/init.d/dnsmasq restart

echo 'Goto http://'"${NET_ADDR}"':3000 and configure AdGuardHome.'

sleep 5
echo
echo ----- SET CLOUDFLARE WAN DNS -----
# Disable peer ISP DNS
uci set network.wan.peerdns="0"

# Reconfigure router IPv4 DNS provider to cloudflare upstream
uci -q delete network.wan.dns
uci add_list network.wan.dns="1.1.1.1"
uci add_list network.wan.dns="1.0.0.1"
 
# Save changes
uci commit network

# Restart network service to reflect changes
/etc/init.d/network restart
reboot
