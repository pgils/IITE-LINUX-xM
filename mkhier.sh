#!/bin/bash
#

TARGETFS=${CLFS_TARGET_FS}
[ -n "${TARGETFS}" ] || TARGETFS="_rootfs"

# http://clfs.org/view/clfs-embedded/arm/cross-tools/create-targetfs.html
mkdir -pv ${TARGETFS}
# http://clfs.org/view/clfs-embedded/arm/final-system/creatingdirs.html
mkdir -pv ${TARGETFS}/{bin,boot,dev,etc,home,lib/{firmware,modules}}
mkdir -pv ${TARGETFS}/{mnt,opt,proc,sbin,srv,sys}
mkdir -pv ${TARGETFS}/var/{cache,lib,local,lock,log,opt,run,spool}
install -dv -m 0750 ${TARGETFS}/root
# do _not_ create /var/tmp here. It is symlinked on startup.
install -dv -m 1777 ${TARGETFS}/tmp
mkdir -pv ${TARGETFS}/usr/{,local/}{bin,include,lib,sbin,share,src}

# http://clfs.org/view/clfs-embedded/arm/final-system/creatingfiles.html
ln -svf ../proc/mounts ${TARGETFS}/etc/mtab

touch ${TARGETFS}/var/log/lastlog
chmod -v 664 ${TARGETFS}/var/log/lastlog

# http://clfs.org/view/clfs-embedded/arm/bootable/fstab.html
# http://clfs.org/view/clfs-embedded/arm/bootscripts/mdev.html
# http://clfs.org/view/clfs-embedded/arm/bootscripts/profile.html
# http://clfs.org/view/clfs-embedded/arm/bootscripts/inittab.html
# http://clfs.org/view/clfs-embedded/arm/bootscripts/hostname.html
# http://clfs.org/view/clfs-embedded/arm/bootscripts/hosts.html
#
# iana-etc: Fetching raw data from IANA with gawk results in a 403 HTTP error.
# so `/etc/{protocols,services}` from Debian buster are included.
cp -av ./etc ${TARGETFS}/
cp -av ./bin ${TARGETFS}/
[ -d ./secret ] && \
    cp -av ./secret/* ${TARGETFS}/
