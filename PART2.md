# Cross-Compiled Linux From Scratch - Embedded
## On a BeagleBoard-xM (rev. C)

TODO:
- webserver

This document:
- Install the needed software to connect the BeagleBoard to a wifi network.
  - *ASUS USB-N10 NANO Wireless-n adapter (RTL8192CU) is used*
- Install Wireguard tools.

### [Connecting to a wireless access points (wiki.alpinelinux.org)][3]

### Prerequisites
- Cross-compile tools and basic system software are installed as described in the [CLFS-E handbook][1]
- Environment is set up according to [CLFS-E handbook][2] with an additional variable:
  - ```CLFS_TARGET_FS="${CLFS}/targetfs"```
- `${CLFS_TARGET_FS}` has been populated by the [mkhier.sh script](mkhier.sh)
- [Basic system software][4] is installed in `${CLFS_TARGET_FS}`

[1]: http://clfs.org/view/clfs-embedded/arm/
[2]: http://clfs.org/view/clfs-embedded/arm/cross-tools/variables.html
[3]: https://wiki.alpinelinux.org/wiki/Connecting_to_a_wireless_access_point
[4]: http://clfs.org/view/clfs-embedded/arm/final-system/introduction.html

## Table of contents
-   [Compiling and installing](#compiling-and-installing)  
  - [Linux](#linux)  
  - [wpa_supplicant](#wpasupplicant)  
      - [libnl](#libnl)  
      - [OpenSSL](#openssl)  
      - [wpa_supplicant](#wpasupplicant)  
  - [wireless-tools](#wireless-tools)
- [Packaging](#packaging)  
  - [U-boot](#u-boot)  
  - [Tarball](#tarball)  

## Compiling and installing
### Linux
source: git://git.kernel.org/pub/scm/linux/kernel/git/torvalds linux.git  
branch: master  
defconfig: omap2plus_defconfig  

```
make ARCH=${CLFS_ARCH} CROSS_COMPILE=${CLFS_TARGET}- omap2plus_defconfig
make ARCH=${CLFS_ARCH} CROSS_COMPILE=${CLFS_TARGET}- menuconfig
```
##### legacy hotplug (Busybox mdev)
```
Device Drivers  --->
    Generic Driver Options  --->
        [*] Support for uevent helper
        (/sbin/mdev) path to uevent helper
```
##### Wireguard
```
Device Drivers  ---> 
    [*] Network device support  --->
        [*]   Network core driver support 
        ...
        <*>     WireGuard secure network tunnel
```
##### rtl8192cu (ASUS USB-N10 NANO Wireless-n adapter)
```
Device Drivers  ---> 
    [*] Network device support  --->
        [*]   Wireless LAN  --->
            [*]   Realtek devices 
            ...
            <*>     Realtek rtlwifi family of devices  --->
                <*>   Realtek RTL8192CU/RTL8188CU USB Wireless Network Adapter  
```
**Additional firmware is required:**  
/lib/firmware/rtlwifi/rtl8192cufw_TMSC.bin
##### wireless extensions compatibility (wireless-tools + wpa_supplicant)
```
[*] Networking support  --->
    [*] Wireless  --->
        <*> cfg80211 - wireless configuration API
        [*]     cfg80211 wireless extensions compatibility
        <*> Generic IEEE 802.11 Networking Stack (mac80211)
```
##### RFkill (wpa_supplicant)
```
[*] Networking support  --->
    <*>   RF switch subsystem support  --->
```
##### Disable GPU/DRM and Sound
*Compiling `OMAP2_DSS` statically into the kernel results in kernel panic on reboot.*  
```
Device Drivers  --->
    Graphics support  --->
        < > OMAP DRM
    < > Sound card support  --->
```

#### Statically include all modules
Set all drivers to be included statically.
```
sed -ie "s/=m/=y/g" .config
```

#### Make and install
```
make ARCH=${CLFS_ARCH} CROSS_COMPILE=${CLFS_TARGET}- -j$(nproc)
cp arch/arm/boot/{zImage,dts/omap3-beagle-xm.dtb} ${CLFS_TARGET_FS}/boot/
```

### wpa_supplicant
Dependencies `libnl` and `openssl` are installed first.

Sources
- [Cross compile wpa_supplicant][10]
- [wpa_supplicant - LFS][11]
- [libnl - LFS][12]

#### libnl
source: https://github.com/thom311/libnl  
release: 3.5.0  

```
cd libnl-3.5.0
./configure --prefix=${CLFS_TARGET_FS}/usr --host=${CLFS_TARGET} --disable-static
make
make install
```

#### OpenSSL
source: https://github.com/openssl/openssl  
release: 1.1.1d  

```
cd openssl-1.1.1d
ARCH=${CLFS_ARCH} ./Configure --prefix=${CLFS_TARGET_FS}/usr linux-armv4
make
make install_sw
```
*`make install_sw` installs the software components only*

#### wpa_supplicant
source: https://w1.fi/wpa_supplicant/  
release: 2.9  

```
cd wpa_supplicant-2.9/wpa_supplicant
cp defconfig .config
```
Edit `.config`
- disable DBus support  
  ```
  ...
  #CONFIG_CTRL_IFACE_DBUS_NEW=y
  #CONFIG_CTRL_IFACE_DBUS_INTRO=y
  ...
  ```
- Add
  ```
  DESTDIR  = ${CLFS_TARGET_FS}
  CFLAGS  += -I$(DESTDIR)/usr/include/libnl3
  LDFLAGS += -L$(DESTDIR)/usr/lib
  ```
```
make
make BINDIR=/sbin LIBDIR=/lib install
```
*defaults for `bin` and `lib` are in `/usr/local/`*

### wireless-tools
[clfs.org][13]

### Wireguard-tools
source: https://git.zx2c4.com/wireguard-tools  
branch: master

```
make ARCH=${CLFS_ARCH} CROSS_COMPILE=${CLFS_TARGET}- -C src -j$(nproc)
install -v -m 0755 src/wg ${CLFS_TARGET_FS}/usr/bin/wg
```
*Only the `wg` binary is installed. `make install` installs bash completion, man pages etc.*


## Packaging
### U-boot
Compiling: [Part 1](README.md)
```
cp {u-boot.img,MLO} ${CLFS_TARGET_FS}/boot/
```

### Tarball
```
# mktarball.sh ${CLFS_TARGET_FS}
```

[10]: https://drzhf9.wordpress.com/2013/11/08/cross-compile-wpa_supplicant/
[11]: http://www.linuxfromscratch.org/blfs/view/svn/basicnet/wpa_supplicant.html
[12]: http://www.linuxfromscratch.org/blfs/view/svn/basicnet/libnl.html
[13]: http://clfs.org/view/clfs-embedded/arm/beyond/wireless_tools.html
