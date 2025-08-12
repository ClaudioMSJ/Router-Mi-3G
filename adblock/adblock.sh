#!/bin/sh

OISD_URL="https://raw.githubusercontent.com/sjhgvr/oisd/refs/heads/main/domainswild_small.txt"
OISD_GZ="/etc/oisd_small.hosts.gz"
OISD_TMP="/tmp/oisd_small.hosts"
OISD_INIT="/etc/init.d/adblock"

echo "[*] Baixando e compactando lista OISD small..."
wget -qO- "$OISD_URL" | grep -v '^#' | grep -v '^$' | sed 's/^/0.0.0.0 /' | gzip -9 > "$OISD_GZ"

if [ ! -s "$OISD_GZ" ]; then
    echo "[!] Falha no download ou compressão."
    exit 1
fi

echo "[*] Criando script de inicialização..."
cat > "$OISD_INIT" <<EOF
#!/bin/sh /etc/rc.common
START=19
STOP=89

start() {
    echo "[adblock] Descompactando lista para RAM..."
    gzip -dc $OISD_GZ > $OISD_TMP
    if ! grep -q "addn-hosts=$OISD_TMP" /etc/dnsmasq.conf; then
        echo "addn-hosts=$OISD_TMP" >> /etc/dnsmasq.conf
    fi
    /etc/init.d/dnsmasq restart
}

stop() {
    echo "[adblock] Limpando lista da RAM..."
    rm -f $OISD_TMP
}

update() {
    echo "[adblock] Atualizando lista OISD small..."
    wget -qO- "$OISD_URL" | grep -v '^#' | grep -v '^$' | sed 's/^/0.0.0.0 /' | gzip -9 > "$OISD_GZ"
    if [ -s "$OISD_GZ" ]; then
        echo "[adblock] Lista atualizada com sucesso."
        /etc/init.d/adblock start
    else
        echo "[adblock] ERRO ao atualizar."
    fi
}
EOF

chmod +x "$OISD_INIT"

echo "[*] Configurando atualização semanal via cron..."
grep -q 'adblock update' /etc/crontabs/root || \
    echo '0 4 * * 1 /etc/init.d/adblock update' >> /etc/crontabs/root
/etc/init.d/cron restart

echo "[*] Ativando script..."
$OISD_INIT enable
$OISD_INIT start

echo "[✓] OISD small instalado e atualização semanal configurada."
