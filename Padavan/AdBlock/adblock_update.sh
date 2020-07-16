sleep 9
PATH=/opt/sbin:/opt/bin:/opt/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

rm /opt/tmp/block.hosts
touch /opt/tmp/block.hosts
sleep 8

# 0.0.0.0 is defined as a non-routable meta-address used to designate an invalid, unknown, or non applicable target. Using 0.0.0.0 is empirically faster, possibly because there's no wait for a timeout resolution
ENDPOINT_IP4="0.0.0.0"
TMPDIR="/opt/tmp/block.build.list"
STGDIR="/opt/tmp/block.build.before"
TARGET="/opt/tmp/block.hosts"
BLIST="/opt/tmp/adblock_black.list"
WLIST="/opt/tmp/adblock_white.list"

# Download and process the files needed to make the lists (enable/add more, if you want)

#youtube ads blacklist
wget -qO- "https://raw.githubusercontent.com/anudeepND/youtubeadsblacklist/master/hosts.txt" | awk -vr="0.0.0.0" '{sub(/^0.0.0.0/, r)} $0 ~ "^"r' >> "$TMPDIR"

#youtube ads blacklist
wget -qO- "https://raw.githubusercontent.com/HenningVanRaumle/pihole-ytadblock/master/ytadblock.txt"  | awk -vr="0.0.0.0" '{sub(/^0.0.0.0/, r)} $0 ~ "^"r' >> "$TMPDIR"

#youtube ads blacklist
wget -qO- "https://jasonhill.co.uk/pfsense/ytadblock.txt" | awk -vr="0.0.0.0" '{sub(/^0.0.0.0/, r)} $0 ~ "^"r' >> "$TMPDIR"

#youtube ads blacklist
wget -qO- "https://raw.githubusercontent.com/kboghdady/youTube_ads_4_pi-hole/master/black.list" | awk -vr="0.0.0.0" '{sub(/^0.0.0.0/, r)} $0 ~ "^"r' >> "$TMPDIR"

#Steven Porn
wget -qO- "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts" | awk -vr="0.0.0.0" '{sub(/^0.0.0.0/, r)} $0 ~ "^"r' >> "$TMPDIR"


# Add black list, if non-empty
if [ -s "$BLIST" ]
then
    awk -v r="$ENDPOINT_IP4" '/^[^#]/ { print r,$1 }' "$BLIST" >> "$TMPDIR"
fi


# Sort the download/black lists
awk '{sub(/\r$/,"");print $1,$2}' "$TMPDIR" | sort -u > "$STGDIR"


# Filter (if applicable)
if [ -s "$WLIST" ]
then
    # Filter the blacklist, suppressing whitelist matches
    # This is relatively slow
    egrep -v "^[[:space:]]*$" "$WLIST" | awk '/^[^#]/ {sub(/\r$/,"");print $1}' | grep -vf - "$STGDIR" > "$TARGET"
else
    cat "$STGDIR" > "$TARGET"
fi


# Delete files used to build list to free up the limited space
rm -f "$TMPDIR" "$STGDIR"

# Restart dnsmasq
killall -SIGHUP dnsmasq