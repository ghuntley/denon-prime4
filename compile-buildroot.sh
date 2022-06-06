#!/bin/sh -e
./clone-buildroot.sh
make -C buildroot/*/ -j$(nproc)
tar -c -v -C buildroot/*/output/target/ --owner=root --group=root \
	$(cat buildroot/2021.02.10/output/build/packages-file-list.txt | grep openssh | tr ',' ' ' | awk '{print $2}') \
	| \
sudo ./mount.sh --write tar -xp
sudo ./mount.sh --write systemctl enable sshd
if ! sudo ./mount.sh grep -q sshd /etc/group; then
  sudo ./mount.sh --write /sbin/addgroup -S sshd
fi
if ! sudo ./mount.sh grep -q sshd /etc/passwd; then
  sudo ./mount.sh --write /sbin/adduser -H -S -D -G sshd -h /var/empty sshd
fi
