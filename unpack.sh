#!/bin/sh -e

prime4_update_download_url="https://imb-cicd-public.s3.amazonaws.com/Engine/2.2.1/Release/EOS/7f52008ad1/PRIME4-2.2.1-Update.img"
prime4_update_download_filename="${prime4_update_download_url##*/}"

log() {
  echo "$@" >&2
}

log_fatal() {
  echo "ERROR:" "$@" >&2
  exit 1
}

if ! command -v dumpimage >/dev/null; then
  log_fatal "You need u-boot-tools installed (dumpimage command seems to be missing)."
fi

files=( $(find -mindepth 1 -maxdepth 1 -name \*.img ) )

download_firmware() {
  log "*** Downloading ${prime4_update_download_filename}"
  curl '-#Lo' "${prime4_update_download_filename}" "${prime4_update_download_url}"
  files+=( "${prime4_update_download_filename}" )
}

if [ "${#files[@]}" -lt 1 ]; then
  #log_fatal "Need at least one .img file to process. Put it into the current working directory ($(pwd))."
  download_firmware
fi

for file in "${files[@]}"; do
  #log "*** Extracting kernel and DTB"
  #extract-dtb "$file" -o unpacked-img/

  #for dtb in unpacked-img/*.dtb; do
  for dtb in "$file"; do
    log "*** Converting $dtb to DTS"
    dtc -I dtb -O dts "$dtb" > "$dtb.dts"

    log "*** Unpacking $dtb"
    mkdir -p unpacked-img
    dumpimage -l "$dtb"
    dumpimage -T flat_dt -p 0 -o unpacked-img/splash.img.xz "$dtb"
    rm unpacked-img/splash.img
    xz -f -vd unpacked-img/splash.img.xz
    dumpimage -T flat_dt -p 1 -o unpacked-img/recoverysplash.img.xz "$dtb"
    rm -f unpacked-img/recoverysplash.img
    xz -vd unpacked-img/recoverysplash.img.xz
    dumpimage -T flat_dt -p 2 -o unpacked-img/rootfs.img.xz "$dtb"
    rm -f unpacked-img/rootfs.img
    xz -vd unpacked-img/rootfs.img.xz
  done
done