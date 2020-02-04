#!/bin/sh

WG_INT="wg0"
IP="10.20.10.2"
ROUTE="10.20.10.0/24"
CONF="/etc/wireguard/wg0.conf"

case "${1}" in
"start")
    iplink add dev "${WG_INT}" type wireguard
    ifconfig "${WG_INT}" "${IP}"
    route add -net "${ROUTE}" dev "${WG_INT}"
    wg setconf "${WG_INT}" "${CONF}"
    iplink set up dev "${WG_INT}"
    ;;
"stop")
    iplink delete "${WG_INT}"
    ;;
esac