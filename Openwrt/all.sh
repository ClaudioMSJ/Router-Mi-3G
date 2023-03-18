#!/bin/sh

opkg update

###############################################################################

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

################################################################################

# Install packages
opkg install curl
opkg --force-overwrite install gawk grep sed

# Install Simple Adblock
opkg install simple-adblock luci-app-simple-adblock

# Cofiguration
uci set simple-adblock.config.enabled=1
uci set simple-adblock.config.download_timeout='60'
uci commit simple-adblock

################################################################################

# Install Stubby
opkg install stubby

# Enable DNS encryption
/etc/init.d/dnsmasq stop
uci set dhcp.@dnsmasq[0].noresolv="1"
uci set dhcp.@dnsmasq[0].localuse="1"
uci -q delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server="127.0.0.1#5453"
uci commit dhcp
/etc/init.d/dnsmasq restart

# Add resolvers
uci set stubby.dnsa="resolver"
uci set stubby.dnsa.address="1.1.1.1"
uci set stubby.dnsa.tls_auth_name="one.one.one.one"
uci set stubby.dnsb="resolver"
uci set stubby.dnsb.address="1.0.0.1"
uci set stubby.dnsb.tls_auth_name="one.one.one.one"
uci set stubby.dnsc="resolver"
uci set stubby.dnsc.address="8.8.8.8"
uci set stubby.dnsc.tls_auth_name="dns.google"
uci set stubby.dnsd="resolver"
uci set stubby.dnsd.address="8.8.4.4"
uci set stubby.dnsd.tls_auth_name="dns.google"
uci commit stubby
/etc/init.d/stubby restart

# DNS leak test from command line
curl https://raw.githubusercontent.com/macvk/dnsleaktest/master/dnsleaktest.sh | bash
