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


