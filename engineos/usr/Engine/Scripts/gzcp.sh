#!/bin/sh

BASENAME=`basename "$1"`

echo "$2/$BASENAME.xz"
if [ ! -f "$2/$BASENAME.xz" ]; then
        /bin/pixz -2 -p 4 -t < "$1" > "$2/$BASENAME.xz"
fi

