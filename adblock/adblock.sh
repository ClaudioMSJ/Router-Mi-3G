curl -k https://raw.githubusercontent.com/hagezi/dns-blocklists/main/dnsmasq/pro.txt -o /etc/dnsmasq.conf   2>/dev/null ; echo ok 

uci commit dhcp
/etc/init.d/dnsmasq restart 
