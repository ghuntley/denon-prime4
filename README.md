# Customized Denon Prime 4 Firmware

This repository contains the efforts done to create and flash custom firmware for the Denon Prime 4. This may also be relevant to other Denon DJ equipment, however the main efforts are focused on the Denon Prime 4.

## Setup

Steps below have only been tested on an Arch Linux system. Basic development packages (for example `build-essentials` or `base-devel` package), u-boot tools and 7-zip are required to be installed on your system.

To reproduce the modified firmware with OpenSSH:

1. Run `./unpack.sh` to download and unpack the original firmware package.
2. Run `./clone-buildroot.sh` to download the matching buildroot environment via Git to the `buildroot/2021.02.10` directory.
3. Run `./compile-buildroot.sh` to build the required toolchain and packages in buildroot. Note that this will ask for sudo access to modify the unpacked firmware images via loopback mount.
4. Run `./pack.sh` to finally pack the modified image files back into a new firmware package. It will have a `.dtb` extension but you can rename this to `.img` and flash it directly to your hardware.
5. Optionally run `./unpack-updater.sh` to download Denon's original Windows tool for flashing firmware via USB cable, then run `./generate-updater-win.sh` to download 7-zip's SFX module to generate a self-extracting executable based on that tool but with your own image instead.

## Customizations

- Use `./mount.sh` to chroot into unpacked rootfs at any time.
- Use `./mount.sh --write` to chroot into rootfs without read-only flags set. Do your modifications and exit the shell, and it will be stored in the rootfs.
- You can pass any command to `./mount.sh` such as `(echo YourPassword123 && echo YourPassword123) | ./mount.sh --write passwd` for scripting.

## Information

### Buildroot

The rootfs seems to be built using Buildroot 2021.02.10 with the kernel version being `5.10.109-inmusic-2022-03-30-rt64 #1 SMP PREEMPT_RT Wed May 18 00:35:15 UTC 2022 armv7l GNU/Linux` at the time of writing this.

This repository makes use of that fact to build software in an easy manner.

### Firmware update source

The firmware pulls the latest firmware and its URL from https://autoupdate.airmusictech.com/PrimeUpdates.xml.

Information below is from the original repository by @ghuntley.

---

# denon prime4 firmware research

## notes

* JC11 = Denon Prime 4 codename.
* Effects unit / controller MIDI definitions are at https://github.com/ghuntley/denon-prime4/blob/trunk/engineos/usr/Engine/AssignmentFiles/PresetAssignmentFiles/JC11/JC11_Controller_Assignments.qml
* static arm binaries for ssh / netcat at https://github.com/TheKikGen/MPC-LiveXplore and https://github.com/TheKikGen/MPC-LiveXplore-bootstrap
* repacking firmware at https://github.com/TheKikGen/MPC-LiveXplore/blob/master/imgmaker/mpcimg
* engineos library format at https://github.com/mixxxdj/mixxx/wiki/Engine-Library-Format


## inspecting the firmware

```
$ file PRIME4-2.2.1-Update.img 
PRIME4-2.2.1-Update.img: Device Tree Blob version 17, size=141671335, boot CPU=0, string block size=103, DT structure block size=141670280
```

> The device tree blob is "compiled" by a special compiler that produces the binary in the proper form for U-Boot and Linux to understand.

```
$ brew install u-boot-tools
$ sudo apt-get install u-boot-tools
```

```
$ dumpimage -l PRIME4-2.2.1-Update.img          
FIT description: JC11 upgrade image
Created:         Wed May 18 07:14:06 2022
 Image 0 (splash)
  Description:  Splash screen
  Created:      Wed May 18 07:14:06 2022
  Type:         Unknown Image
  Compression:  Unknown Compression
  Data Size:    4976 Bytes = 4.86 KiB = 0.00 MiB
  Hash algo:    sha1
  Hash value:   6c80d25a71311d1b385adbd598bfe7309b716767
 Image 1 (recoverysplash)
  Description:  Update mode splash screen
  Created:      Wed May 18 07:14:06 2022
  Type:         Unknown Image
  Compression:  Unknown Compression
  Data Size:    5520 Bytes = 5.39 KiB = 0.01 MiB
  Hash algo:    sha1
  Hash value:   f2f25f8a52f4a9cbba8d89e25f45dead69aefdca
 Image 2 (rootfs)
  Description:  Root filesystem
  Created:      Wed May 18 07:14:06 2022
  Type:         Unknown Image
  Compression:  Unknown Compression
  Data Size:    141659132 Bytes = 138339.00 KiB = 135.10 MiB
  Hash algo:    sha1
  Hash value:   e845bd36f1be5368fb0d5b113f0ca68a5e949aa5
```

### extracting the firmware

```
dumpimage -T flat_dt -p 0 -o splash.xz PRIME4-2.2.1-Update.img 
dumpimage -T flat_dt -p 1 -o recovery.xz PRIME4-2.2.1-Update.img
dumpimage -T flat_dt -p 2 -o rootfs.xz PRIME4-2.2.1-Update.img
```

```
sudo apt-get install xz-utils p7zip e2tools
```

```
xz -d splash.xz
xz -d recovery.xz
xz -d rootfs.xz
```


```
$ e2ls rootfs
bin          boot         dev          etc          home         lib          
lib32        linuxrc      lost+found   media        mnt          opt          
proc         root         run          sbin         srv          sys          
tmp          usr          var          
```
