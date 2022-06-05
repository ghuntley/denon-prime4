#!/bin/sh -e

log() {
  echo "$@" >&2
}

log_fatal() {
  echo "ERROR:" "$@" >&2
  exit 1
}

if [ ! -f unpacked-img/rootfs.img ]; then
  log_fatal "You need to unpack the original firmware first (unpacked-img/rootfs.img seems to be missing)."
fi

mkdir -p engineos media/az01-internal
chmod 777 media/az01-internal
# NOTE - potential backfiring possible if recursively unmounting /dev/
trap 'umount engineos/dev; umount -R engineos' EXIT
mount -o ro unpacked-img/rootfs.img engineos
mount --bind /dev engineos/dev
mount --bind media engineos/media
mount -t proc proc engineos/proc
mount -t tmpfs run engineos/run
mount -t sysfs sys engineos/sys
mount -t tmpfs sys_firmware engineos/sys/firmware
mkdir engineos/sys/firmware/devicetree
mount --bind -o ro devicetrees/JC11 engineos/sys/firmware/devicetree
mount -t tmpfs tmp engineos/tmp

if [ "$#" -lt 1 ]
then
  set -- sh -i
fi
chroot engineos sh -c "export LC_ALL=C; unset LANGUAGE; exec \"\$@\"" -- "$@"
