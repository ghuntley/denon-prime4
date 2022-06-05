#!/bin/sh

case "$(cat /sys/firmware/devicetree/base/inmusic,product-code)" in
JC11)
	hostname=prime4
	pretty_hostname="Denon DJ PRIME4"
	;;
*)
	exit 0
	;;
esac

hostnamectl set-hostname --static "$hostname"
hostnamectl set-hostname --pretty "$pretty_hostname"
hostnamectl set-hostname --transient ""
