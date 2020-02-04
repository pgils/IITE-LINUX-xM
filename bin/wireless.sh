#!/bin/sh

WLAN_INTERFACE="${2}"
WPA_SUPPLICANT_CONFIG="/etc/wpa_supplicant.conf"
UDHCPC_SCRIPT="/etc/udhcpc/simple.sh"

case "${1}" in
"start")
    ifconfig "${WLAN_INTERFACE}" up
    wpa_supplicant -B -i "${WLAN_INTERFACE}" \
        -c "${WPA_SUPPLICANT_CONFIG}"
    udhcpc -s "${UDHCPC_SCRIPT}" -i "${WLAN_INTERFACE}"
    ;;
"stop")
    killall udhcpc
    killall wpa_supplicant
    ifconfig "${WLAN_INTERFACE}" down
    ;;
"restart")
    ${0} "${WLAN_INTERFACE}" stop
    ${0} "${WLAN_INTERFACE}" start
    ;;
*)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
esac