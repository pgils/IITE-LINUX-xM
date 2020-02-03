# Cross-Compiled Linux From Scratch - Embedded
## On a BeagleBoard-xM (rev. C)

This document:
- Booting a linux kernel with U-boot  
- Minimal filesystem hierarchy  
- Log in on a getty on serial port  

**[Part 2: installing additional software](PART2.MD)** 

## Host system
```
builder@beagle-build ~ % cat /etc/os-release
PRETTY_NAME="Debian GNU/Linux 10 (buster)"
...
builder@beagle-build ~ % arm-linux-gnueabihf-gcc --version
arm-linux-gnueabihf-gcc (Debian 8.3.0-2) 8.3.0
...
builder@beagle-build ~ % cat .zshrc.local
...
ARCH=arm
CROSS_COMPILE=arm-linux-gnueabihf-
...
```
### Packages
TODO: package (for)
- build-essential
- gcc-arm-linux-gnueabihf
- bison
- flex
- bc
- libncurses-dev
- libssl-dev
- kmod (?)
- rsync (kernel headers_install)
- makeinfo (binutils)

## SD-CARD
https://archlinuxarm.org/platforms/armv7/ti/beagleboard-xm  

disk label: msdos
```
Device          Boot Size    Id  Type               Fs
----------------------------------------------------------
/dev/mmcblk0p1  *    100M    c   Win95 FAT32 (LBA)  FAT16
/dev/mmcblk0p2       7479M   83  Linux              ext4
```

## U-BOOT
source:     git://git.denx.de/u-boot.git  
tag:        v2019.10  
defconfig:  omap3_beagle_defconfig  

#### EHCI errors
`u-boot` > v2019.10 throws EHCI timeouts:  
TODO: biscect
```
EHCI timed out on TD - token=0x80008c80
EHCI timed out on TD - token=0x80008c80
EHCI timed out on TD - token=0x80008d80
EHCI timed out on TD - token=0x80008c80
EHCI timed out on TD - token=0x80008c80
```
#### Bootcommand
Configuring the bootcommand for automatic loading of the kernel:
```
[*] Enable a default value for bootcmd
  (fatload mmc 0:1 0x80008000 zImage;fatload mmc 0:1 0x82000000 omap3-beagle-xm.dtb;bootz 0x80008000 - 82000000) bootcmd value
```
With the default `env` and configured `bootcommand` there is no need to store/load `env` so it can be disabled:
```
Environment  --->  
    [*] Environment is not stored
    ...
    [ ] Environment in a NAND device
    ...
```
#### Make and install
```
make
cp {u-boot.img,MLO} /path/to/sdcard/boot/
```
## Linux
source:     git://git.kernel.org/pub/scm/linux/kernel/git/torvalds  linux.git  
branch:     master    
defconfig:  omap2plus_defconfig  
  
_`master` branch is used as there has not yet been a release (5.6) since the merge of Wireguard at the time of writing._

#### Hotplug
```
/etc/rc.d/startup: line 13: can't create /proc/sys/kernel/hotplug: nonexistent directory
```
busybox's `mdev` which is used in CLFS-E needs legacy hotplug support.
```
Device Drivers  --->
    Generic Driver Options  --->
        [*] Support for uevent helper
```
#### Make and install
```
make
cp arch/arm/boot/{zImage,dts/omap3-beagle-xm.dtb} /path/to/sdcard/boot/
```

## Filesystem hierarchy
Directories and files are created per the CLFS-E handbook with the following exceptions:
#### /var/tmp
the `startup` init script will symlink `/tmp` (tmpfs) to `/var/tmp`. If `/var/tmp` is a directory this will result in the link `/var/tmp/tmp` on first startup and
```
ln: failed to create symbolic link '/var/tmp/tmp': File exists
```
on the second start. Therefore **skip creating `/var/tmp`**.  
#### /etc/services, /etc/protocols
Fetching raw data from IANA with the `gawk` scripts provided by the `iana-etc` package results in HTTP errors
```
Status 403 Forbidden: User-Agent required. Contact iana@iana.org with questions.
```
Prebuilt files from the [`netbase` debian package][10] are used instead.
```
cp /etc/{services,protocols} /path/to/targetfs/etc/
```
## Software
### Busybox
source:     git://git.busybox.net/busybox  
branch:     master  
defconfig:  defconfig  

#### Static
```
Settings  --->
    [*] Build static binary (no shared libs)
```
#### Make and install
```
make install
cp -r _install/* /path/to/targetfs/
```

### Bootscripts
source:     https://github.com/cross-lfs/bootscripts-embedded.git  
branch:     master  

```
make DESTDIR=/path/to/targetfs install-bootscripts
```

[10]: https://packages.debian.org/buster/all/netbase/filelist