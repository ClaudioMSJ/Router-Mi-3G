wget https://raw.githubusercontent.com/hagezi/dns-blocklists/main/dnsmasq/pro.mini.txt -o /etc/adblock_hosts  2>/dev/null ; echo ok
wget https://raw.githubusercontent.com/hagezi/dns-blocklists/main/dnsmasq/pro.mini.txt -o /etc/dnsmasq.conf   2>/dev/null ; echo ok 

uci set dhcp.@dnsmasq[0].addnhosts='/tmp/adblock_hosts'
uci commit dhcp
/etc/init.d/dnsmasq restart 
