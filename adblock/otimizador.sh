cat << 'EOF' > /root/otimizador.sh
#!/bin/sh

# Lista de serviços críticos que não devem ser parados
CRITICOS="dropbear netifd procd ubusd rpcd log"

# Função para checar se serviço está em uso
servico_em_uso() {
    svc=$1
    # Processo ativo?
    if pgrep -f "$svc" >/dev/null 2>&1; then
        return 0
    fi
    # Conexões de rede ativas?
    if netstat -tunlp 2>/dev/null | grep -q "$svc"; then
        return 0
    fi
    return 1
}

# Função para pegar RAM livre em MB
mem_livre() {
    free -m | awk '/Mem:/ {print $4}'
}

MEM_BEFORE=$(mem_livre)
echo "[RAM antes] $MEM_BEFORE MB livres"

echo
echo "[1/3] Desativando serviços não essenciais e sem uso..."
for svc in $(ls /etc/init.d/); do
    if /etc/init.d/$svc enabled 2>/dev/null; then
        skip=0
        for c in $CRITICOS; do
            [ "$svc" = "$c" ] && skip=1
        done
        if [ $skip -eq 0 ]; then
            if servico_em_uso "$svc"; then
                echo " - $svc está em uso, mantendo ativo"
            else
                /etc/init.d/$svc stop 2>/dev/null
                /etc/init.d/$svc disable 2>/dev/null
                echo " - $svc desativado"
            fi
        fi
    fi
done

echo
echo "[2/3] Matando processos não essenciais..."
for pid in $(ps w | awk 'NR>1 {print $1,$5}' | grep -vE "$(echo $CRITICOS | tr ' ' '|')" | awk '{print $1}'); do
    kill $pid 2>/dev/null
done

echo
echo "[3/3] Limpando cache de RAM..."
sync
echo 3 > /proc/sys/vm/drop_caches

MEM_AFTER=$(mem_livre)
GAIN=$((MEM_AFTER - MEM_BEFORE))

echo
echo "[RAM depois] $MEM_AFTER MB livres"
echo "[✔] Ganho de RAM: ${GAIN} MB"
EOF