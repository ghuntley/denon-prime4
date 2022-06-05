#!/bin/sh

DEVICENAME=$1

if [ -z "$DEVICENAME" ];
then
  exit 1
fi

echo "Copying journalctl to /media/$DEVICENAME/Engine Library/coredumps/journalctl/"
mkdir -p "/media/$DEVICENAME/Engine Library/coredumps/journalctl/"
journalctl | gzip -c > "/media/$DEVICENAME/Engine Library/coredumps/journalctl/$(date +"%Y-%m-%d__%H-%M-%S").log.gz"
