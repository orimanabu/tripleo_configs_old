#!/bin/bash

if [ x"$#" != x"1" ]; then
        echo "$0 node"
        exit 1
fi
node=$1; shift

#user=root
user=heat-admin

source ~/stackrc

#addr=$(nova show ${node} | awk '/ctlplane network/ {print $5}')

line=$(nova list | grep -i ${node})
#echo "line = ${line}"
num_nodes=$(echo "${line}" | wc -l)
#echo "num_nodes = ${num_nodes}"
if [ x"$num_nodes" != x"1" ]; then
        echo "! '${node}' is not unique."
        echo "${line}" | awk '{print $4}'
        exit 1
fi
node=$(echo "${line}" | awk '{print $4}')
addr=$(echo "${line}" | awk '{print $12}' | sed -e 's/ctlplane=//')
echo "* node = $node"
echo "* addr = $addr"

ping -c 1 -W 1 ${addr} > /dev/null 2>&1
if [ x"$?" != x"0" ]; then
        echo "${addr} is not reachable."
        exit 1
fi
ssh-keygen -R ${addr}
ssh -e none -o StrictHostKeyChecking=no -l ${user} ${addr}
