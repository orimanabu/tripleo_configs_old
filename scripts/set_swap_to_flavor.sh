#!/bin/bash

swap_size_gb=1
swap_size_mb=$(echo "${swap_size_gb} * 1024" | bc)
sudo mysql nova_api -e "UPDATE flavors SET swap = ${swap_size_mb} WHERE name = 'control'"
sudo mysql nova_api -e "UPDATE flavors SET swap = ${swap_size_mb} WHERE name = 'compute'"
