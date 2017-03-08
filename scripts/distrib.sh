#!/bin/bash

source ~/stackrc
user=root

if [ x"$#" = x"0" ]; then
	echo "$0 op"
	exit 1
fi
op=$1; shift

case ${op} in
test)
	openstack server list --name ctrl -f value -c ID -c Name -c Networks | while read id name network; do
		addr=$(echo ${network} | sed -e 's/^ctlplane=//')
		#echo "* id=$id, name=$name, addr=$addr"
		ssh -n -l ${user} ${addr} "$*" | sed -e "s/^/${name}: /"
	done
	;;
get)
	if [ x"$#" != x"2" ]; then
		echo "$0 get HOST PATH"
		exit 1
	fi
	host=$1; shift
	path=$1; shift
	addr=$(openstack server list --name ${host} -f value -c ID -c Name -c Networks | awk '{print $3}' | sed -e 's/^ctlplane=//')
	scp ${user}@${addr}:${path} .
	;;
suget)
	if [ x"$#" != x"2" ]; then
		echo "$0 suget HOST PATH"
		exit 1
	fi
	host=$1; shift
	path=$1; shift
	addr=$(openstack server list --name ${host} -f value -c ID -c Name -c Networks | awk '{print $3}' | sed -e 's/^ctlplane=//')
	ssh -l ${user} ${addr} sudo cp ${path} ~
	scp ${user}@${addr}:$(basename ${path}) .
	;;
put)
	if [ x"$#" != x"2" ]; then
		echo "$0 put SOURCE_PATH DEST_DIR"
		exit 1
	fi
	src=$1; shift
	dst=$1; shift
	openstack server list --name ctrl -f value -c ID -c Name -c Networks | while read id name network; do
		addr=$(echo ${network} | sed -e 's/^ctlplane=//')
		#echo "* id=$id, name=$name, addr=$addr"
		scp -r ${src} ${user}@${addr}:${dst}
	done
	;;
esac
