#!/bin/sh

# Taken from https://openwrt.org/docs/guide-user/services/dns/dot_dnsmasq_stubby
# Provided so it's easy to run from command line

# Install packages
opkg update
opkg install dnsmasq stubby

# Enable DNS encryption
uci -q delete dhcp.@dnsmasq[0].server
uci get stubby.global.listen_address \
| sed -e "s/\s/\n/g;s/@/#/g" \
| while read -r STUBBY_SERV
do
uci add_list dhcp.@dnsmasq[0].server="${STUBBY_SERV}"
done

# Enforce DNS encryption for LAN clients
uci set dhcp.@dnsmasq[0].noresolv="1"

uci commit dhcp

/etc/init.d/dnsmasq restart

# Clear existing stubby config
while uci -q delete stubby.@resolver[0]; do :; done

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

uci set stubby.dns6a="resolver"
uci set stubby.dns6a.address="2606:4700:4700::1111"
uci set stubby.dns6a.tls_auth_name="one.one.one.one"
uci set stubby.dns6b="resolver"
uci set stubby.dns6b.address="2606:4700:4700::1001"
uci set stubby.dns6b.tls_auth_name="one.one.one.one"
uci set stubby.dns6c="resolver"
uci set stubby.dns6c.address="2001:4860:4860::8888"
uci set stubby.dns6c.tls_auth_name="dns.google"
uci set stubby.dns6d="resolver"
uci set stubby.dns6d.address="2001:4860:4860::8844"
uci set stubby.dns6d.tls_auth_name="dns.google"

uci commit stubby

/etc/init.d/stubby restart

# DNS leak test from command line
# curl https://raw.githubusercontent.com/macvk/dnsleaktest/master/dnsleaktest.sh | bash
