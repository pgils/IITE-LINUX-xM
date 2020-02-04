#!/bin/sh

WLAN_INTERFACE="${1}"
WPA_SUPPLICANT_CONFIG="/etc/wpa_supplicant.conf"
UDHCPC_SCRIPT="/etc/udhcpc/simple.sh"

ifconfig "${WLAN_INTERFACE}" up
wpa_supplicant -B -i "${WLAN_INTERFACE}" \
    -c ${WPA_SUPPLICANT_CONFIG}
udhcpc -s ${UDHCPC_SCRIPT} -i "${WLAN_INTERFACE}"