#!/bin/bash

output_interface=eth0
source_subnet=10.10.1.0/24

iptables -t nat -A POSTROUTING -s ${source_subnet} -o ${output_interface} -j MASQUERADE
