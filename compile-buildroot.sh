#!/bin/sh -e
./clone-buildroot.sh
make -C buildroot/*/ -j$(nproc)
tar -c -v -C buildroot/*/output/target/ --owner=root --group=root \
	$(cat buildroot/2021.02.10/output/build/packages-file-list.txt | grep openssh | tr ',' ' ' | awk '{print $2}') \
	| \
sudo ./mount.sh --write tar -xp
sudo ./mount.sh --write systemctl enable sshd
