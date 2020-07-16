#!/bin/bash
x="padavan"
menu ()
{
while true $x != "padavan"
do
clear
echo "================================================"
echo "Mini Script"
echo ""
echo ""
echo "1) AdGuard Home"
echo""
echo "2) AdBlock"
echo ""
echo "3) DnsCrypt"
echo ""
echo "4) Instalar dependências"
echo ""
echo "5) Limpando programas defeituosos "
echo ""
echo "6) Corrigir erros"
echo ""
echo "7) Sair do programa"
echo ""
echo "================================================"

echo "Digite a opção desejada:"
read x
echo "Opção informada ($x)"
echo "================================================"

case "$x" in


    1)
      wget https://github.com/ClaudioMSJ/Router-Mi-3G/raw/master/Padavan/adguardhome_0.102.0-1_mipsel-3.4.ipk
      
      opkg install adguardhome_0.102.0-1_mipsel-3.4.ipk
      
      rm adguardhome_0.102.0-1_mipsel-3.4.ipk
      
      /opt/etc/init.d/S99adguardhome start
      
      sleep 5

echo "================================================"
;;
    2)
    wget -O /opt/tmp/adblock_black.list https://raw.githubusercontent.com/ClaudioMSJ/Router-Mi-3G/master/Padavan/Arquivos%20AdBlock/adblock_black.list
    
    wget -O /opt/tmp/adblock_update.sh https://raw.githubusercontent.com/ClaudioMSJ/Router-Mi-3G/master/Padavan/Arquivos%20AdBlock/adblock_update.sh
    
    wget -O /opt/tmp/adblock_white.list https://github.com/ClaudioMSJ/Router-Mi-3G/raw/master/Padavan/Arquivos%20AdBlock/adblock_white.list
    
      sleep 5
echo "================================================"
;;
   3)
      opkg install dnscrypt-proxy2
      
      wget -O /opt/etc/dnscrypt-proxy.toml https://raw.githubusercontent.com/ClaudioMSJ/Router-Mi-3G/master/Padavan/dnscrypt-proxy.toml
      
      /opt/etc/init.d/S09dnscrypt-proxy2 start
      
      sleep 5
echo "================================================"
;;
    4)
       echo "Iniciando o processo..."
       apt-get -f install
       sleep 5
echo "================================================"
;;
     5)
       echo "Corrigindo erros..."
       apt-get autoremove
       sleep 5
echo "================================================"
;;
    6)
    echo "Reparando..."
    dpkg --configure -a
    sleep 5

echo "================================================"
 ;;
       7)
         echo "saindo..."
         sleep 2
         clear;
         exit;
echo "================================================"
;;

*)
        echo "Opção inválida!"
esac
done

}
menu
