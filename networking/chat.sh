#!/bin/bash

# chat.sh

# A simple Chat 'Server' using netcat. 

# Chris Bugg
# 10/29/18

# M.I.T. Licence, made for DATDA

# Works best on local systems/networks without pesky firewalls and such. 
# Not recommended for use on the open Internetz

# Usage:
#  ./chat.sh [ip of your friend] [port ya'll agreed to chat on]

# Keep 'er going for a while
while true;

# Do dis
do

# Try to connect to a 'server' hosted by your amigo
nc $1 $2

# And when they're not hosting, host yourself!
nc -l localhost $2

# That's all she wrote
done
