#!/bin/sh -e

log() {
  echo "$@" >&2
}

log_fatal() {
  echo "ERROR:" "$@" >&2
  exit 1
}

if ! command -v dtc >/dev/null; then
  log_fatal "dtc command seems to be missing. You need to install the device-tree-compiler for this script to work."
fi

files=( $(find . unpacked-img -mindepth 1 -maxdepth 1 -name \*.dts ) )

if [ "${#files[@]}" -lt 1 ]; then
  log_fatal "Need at least one .dts file to process in either the current working directory or ./unpacked-img/."
fi

for file in "${files[@]}"; do
  dtb="$(basename "$file" .dts).dtb"

  log "*** Converting $file to $dtb"
  dtc -I dts -O dtb "$file" > "$dtb"
done
