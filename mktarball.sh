#!/bin/bash
#

usage() {
	echo "Usage: ${0} <targetfs>"
}

# To set <targetfs> to owner:group 0:0 we need to be root.
[ 0 -eq "$(id -u)" ] || { echo "${0} must be run as root."; exit 1; }

# Check for source (target) filesystem directory
targetfs=${1}
[ -d "${targetfs}" ] || { usage; exit 1; }

# Output tarball
prefix="IITE-LINUX-xM"
today=$(date +%Y-%m-%d)
# https://unix.stackexchange.com/a/506806
seconds=$(date -d "1970-01-01 UTC $(date +%T)" +%s)

tarball="$(pwd)/${prefix}-${today}-${seconds}.tar.xz"

targettmp=$(mktemp -d)
cp -arv "${targetfs}"/* "${targettmp}"

# http://clfs.org/view/clfs-embedded/arm/cleanup/chowning.html
chown -Rv root:root "${targettmp}"
chgrp -v 13 "${targettmp}/var/log/lastlog"
chown -Rv 33:33 "${targettmp}/www"

cd "${targettmp}" || exit 1
tar -cJvf "${tarball}" ./*
cd ..
rm -rv "${targettmp}"

realpath "${tarball}"
