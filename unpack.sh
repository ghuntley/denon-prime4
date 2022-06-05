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

if ! command -v dumpimage; then
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
  log "*** Unpacking $file"
  dumpimage -l "$file"
  dumpimage -T flat_dt -p 0 -o splash.img.xz "$file"
  xz -vd splash.img.xz
  dumpimage -T flat_dt -p 1 -o recoverysplash.img.xz "$file"
  xz -vd recoverysplash.img.xz
  dumpimage -T flat_dt -p 2 -o rootfs.img.xz "$file"
  xz -vd rootfs.img.xz
done
