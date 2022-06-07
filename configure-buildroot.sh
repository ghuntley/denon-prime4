#!/bin/bash -e
#./clone-buildroot.sh
cp -v buildroot-config/.config buildroot/*/
make -C buildroot/*/ -j$(nproc) xconfig
cp -v buildroot/*/.config buildroot-config
