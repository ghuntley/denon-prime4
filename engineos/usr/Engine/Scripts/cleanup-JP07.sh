#!/bin/sh

# Set ethernet ipv4 mode to dhcp ( auto works as well, but conflicts with earlier
# SC5000 version's connman that can't handle it. )
ETH=$(connmanctl services | grep -o ethernet.*)
connmanctl config $ETH --ipv4 dhcp
