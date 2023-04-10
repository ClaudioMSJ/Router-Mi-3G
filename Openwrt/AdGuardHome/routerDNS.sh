#!/bin/sh
# Reconfigure router DNS provider to cloudflare upstream

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
