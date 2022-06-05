#!/bin/sh
#
# This script follows the guide in Documentation/usb/gadget_configfs.txt
#
# You can access the other end of this on a Linux system by binding the
# VID/PID used below to the generic USB-serial driver:
#
#       echo '0001 0001' | sudo tee /sys/bus/usb-serial/drivers/generic/new_id

# systemd automounts configfs at /sys/kernel/config so no need to mount here.
(
    cd /sys/kernel/config &&
    ### Basic device setup:
    mkdir -p usb_gadget/g1 &&
    cd usb_gadget/g1 &&
    # FIXME: dummy VID & PID
    echo 0x0001 >idVendor &&
    echo 0x0001 >idProduct &&
    # note: full list of possible parameters in
    #       Documentation/ABI/testing/configfs-usb-gadget
    mkdir -p strings/0x409 &&
    # FIXME: dummy values below
    echo 1234567890 >strings/0x409/serialnumber &&
    echo 'Dummy Corp.' >strings/0x409/manufacturer &&
    echo 'Dummy Product' >strings/0x409/product &&
    ### Configuration:
    mkdir -p configs/c.1 &&
    (
        cd configs/c.1 &&
        mkdir -p strings/0x409 &&
        echo 'My Configuration' >strings/0x409/configuration &&
        echo 100 >MaxPower
    ) &&
    ### Functions:
    mkdir functions/gser.otg0 &&
    ### Associate functions with configurations:
    ln -s functions/gser.otg0 configs/c.1 &&
    ### Enable the gadget:
    echo ff580000.usb >UDC &&
    sleep 1 &&
    systemctl start serial-getty@ttyGS"$(cat functions/gser.otg0/port_num)"
)
