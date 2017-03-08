#!/bin/bash

export LANG=C
. ~/stackrc
echo "=> start date"
date

echo "=> overcloud deploy"
time openstack overcloud deploy \
--timeout 150 \
--templates ~/templates/tht \
--ntp-server 10.11.160.238 \
--libvirt-type kvm \
--control-scale 3 \
--compute-scale 2 \
--control-flavor control \
--compute-flavor compute \
-e ~/templates/network-environment.yaml \
-e ~/templates/hostname.yaml \
-e ~/templates/ip-address.yaml \
-e ~/templates/storage-environment.yaml \
-e ~/templates/post-environment.yaml \
-e ~/templates/extra-config.yaml \
-e ~/templates/timezone.yaml \
-e ~/templates/rabbitmq.yaml \
-e ~/templates/firstboot-environment.yaml \
-e ~/templates/fencing.yaml \
-e ~/templates/swap.yaml \
$*

echo "=> end date"
date


