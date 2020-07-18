#!/usr/bin/env ash

opkg update
sleep 5

x="padavan"
menu ()
{
while true $x != "padavan"
do
clear
echo "================================================"
echo "Mini Script Padavan"

echo ""
FILE=/opt/etc/init.d/S99adguardhome
if [ -f "$FILE" ]; 
then
echo -e "1) AdGuard Home - \e[32m Status (on) \e[0m" 
else 
echo -e "1) AdGuard Home - \e[31m Status (off) \e[0m"
fi       

echo ""
FILE=/opt/tmp/adblock_update.sh
if [ -f "$FILE" ]; 
then
echo -e "2) AdBlock - \e[32m Status (on) \e[0m" 
else 
echo -e "2) AdBlock - \e[31m Status (off) \e[0m"
fi

echo ""
FILE=/opt/etc/init.d/S09dnscrypt-proxy2
if [ -f "$FILE" ]; 
then
echo -e "3) DNSCrypt - \e[32m Status (on) \e[0m" 
else 
echo -e "3) DNSCrypt - \e[31m Status (off) \e[0m"
fi

echo ""
FILE=/opt/etc/init.d/S48stubby
if [ -f "$FILE" ]; 
then
echo -e "4) Stubby - \e[32m Status (on) \e[0m" 
else 
echo -e "4) Stubby - \e[31m Status (off) \e[0m"
fi

echo ""
echo "5) Periodic Reboot At 06 am "

echo ""
echo "6) Block External DNS"

echo ""
echo "7) Exit Script"

echo ""
echo "8) Exit and Delete Script"

echo ""
echo "================================================"

echo "Enter Number:"
read x
echo "Number Selected ($x)"
echo "================================================"

case "$x" in

    1)
      FILE=/opt/etc/init.d/S99adguardhome
if [ -f "$FILE" ]; 
then
    echo ""
    echo -e "\e[32m Already Installed... \e[0m"
   
else 
      wget -q https://github.com/ClaudioMSJ/Router-Mi-3G/raw/master/Padavan/AdGuard%20Home/adguardhome_0.102.0-1_mipsel-3.4.ipk ;      
      opkg install adguardhome_0.102.0-1_mipsel-3.4.ipk ;      
      rm adguardhome_0.102.0-1_mipsel-3.4.ipk ;      
      /opt/etc/init.d/S99adguardhome start ;      
      wget -O /etc/storage/dnsmasq/dnsmasq.conf https://github.com/ClaudioMSJ/Router-Mi-3G/raw/master/Padavan/DNSCrypt/dnsmasq.conf ;
fi       
     
echo "================================================"
;;
    2)
      FILE=/opt/tmp/adblock_update.sh
if [ -f "$FILE" ]; 
then
    echo ""
    echo -e "\e[32m Already Installed... \e[0m"
else 
    wget -O /opt/tmp/adblock_black.list https://raw.githubusercontent.com/ClaudioMSJ/Router-Mi-3G/master/Padavan/Arquivos%20AdBlock/adblock_black.list ;    
    wget -O /opt/tmp/adblock_update.sh https://raw.githubusercontent.com/ClaudioMSJ/Router-Mi-3G/master/Padavan/Arquivos%20AdBlock/adblock_update.sh ;    
    wget -O /opt/tmp/adblock_white.list https://github.com/ClaudioMSJ/Router-Mi-3G/raw/master/Padavan/Arquivos%20AdBlock/adblock_white.list ;
    fi
 
echo "================================================"
;;
   3)
   FILE=/opt/etc/init.d/S09dnscrypt-proxy2
if [ -f "$FILE" ]; 
then
    echo ""
    echo -e "\e[32m Already Installed... \e[0m"
else
      opkg install dnscrypt-proxy2 ;      
      wget -O /opt/etc/dnscrypt-proxy.toml https://raw.githubusercontent.com/ClaudioMSJ/Router-Mi-3G/master/Padavan/dnscrypt-proxy.toml ;      
      /opt/etc/init.d/S09dnscrypt-proxy2 start ;
fi      
      
echo "================================================"
;;
    4)
     FILE=/opt/etc/init.d/S48stubby
if [ -f "$FILE" ]; 
then
    echo ""
    echo -e "\e[32m Already Installed... \e[0m"
else
       opkg install stubby ;       
       wget -O /opt/etc/stubby/stubby.yml https://raw.githubusercontent.com/blackcofee/guides/master/opt/etc/stubby/stubby.yml ;
       wget -O /opt/etc/init.d/S48stubby https://raw.githubusercontent.com/blackcofee/guides/master/opt/etc/init.d/S48stubby ;       
       chmod +x /opt/etc/init.d/S48stubby ;
       /opt/etc/init.d/S48stubby start ;
fi

echo "================================================"
;;
     5)
     printf '\n0 6 * * * reboot' >> /etc/storage/cron/crontabs/admin ;
    
echo "================================================"
;;
    6)
    printf '\n### Redirect DNS
iptables -t nat -I PREROUTING -i br0 -p udp --dport 53 -j DNAT --to $(nvram get lan_ipaddr)
iptables -t nat -I PREROUTING -i br0 -p tcp --dport 53 -j DNAT --to $(nvram get lan_ipaddr)' >> /etc/storage/post_iptables_script.sh ;    

echo "================================================"
 ;;
       7)
         echo "Exiting..."
         sleep 5;
         clear;
         exit;

echo "================================================"
echo ""
 ;;

       8)
         echo "Exiting and Deleting..."
         rm padavan.sh;
         sleep 5;
         clear;
         exit;

echo "================================================"
echo ""
;;

*)
        echo "Invalid Number!"
esac

read -p "Press enter to back..."

done

}
menu
