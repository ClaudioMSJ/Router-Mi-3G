#!/bin/sh

# Install packages
opkg update
opkg install curl
opkg --force-overwrite install gawk grep sed coreutils-sort

# Install Simple Adblock
opkg install simple-adblock luci-app-simple-adblock

# Cofiguration
uci set simple-adblock.config.enabled=1
uci set simple-adblock.config.download_timeout='60'
uci commit simple-adblock
