#!/bin/bash

output_dir=~/templates/discovered_data
mkdir -p ${output_dir}

#export IRONIC_DISCOVERED_PASSWORD=$(sudo grep admin_password /etc/ironic-inspector/inspector.conf | egrep -v '^#' | awk '{print $NF}')
#export IRONIC_DISCOVERED_PASSWORD=$(sudo grep admin_password /etc/ironic-inspector/inspector.conf | egrep -v '^#' | sed -e 's/^.*=//')
export IRONIC_DISCOVERED_PASSWORD=$(sudo crudini --get /etc/ironic-inspector/inspector.conf swift password)
echo $IRONIC_DISCOVERED_PASSWORD

source ~/stackrc
ironic node-list | awk '/power/ {print $2,$4}' | while read id name; do
        echo "=> id=$id, name=$name"
        swift -U service:ironic -K ${IRONIC_DISCOVERED_PASSWORD} download ironic-inspector inspector_data-${id} -o ${output_dir}/inspector_data-${name}.txt
done
