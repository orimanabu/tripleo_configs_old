#!/bin/bash

workdir=/root/work
mkdir -p ${workdir}

### controller fence / stonith devices

#### ipmilan
#ilo_user=administrator
#ilo_password="ntgQQZ7c!"
#### ipmilan

# run only on ctrl01
hostname | grep ctrl01 > /dev/null 2>&1
if [ x"$?" = x"0" ]; then
	logger -t post-script "### (fence) (on this node)"
	for i in 1 2 3; do
		pcmk_host=osp10-ctrl$(printf "%02d" ${i})
		stonith_dev=fence_xvm_${pcmk_host}

#		### ipmilan
#		ilo_addr=10.1.12.10${i}
#		logger -t post-script "### (fence) stonith_dev=${stonith_dev}, pcmk_host_list=${pcmk_host}, ipaddr=${ilo_addr}"
#		pcs stonith create ${stonith_dev} fence_ipmilan pcmk_host_list=${pcmk_host} ipaddr=${ilo_addr} login=${ilo_user} passwd=${ilo_password} lanplus=1 cipher=1 power_wait=4 op monitor interval=60s
#		### ipmilan

		### kvm
		vm_name=${pcmk_host}
		logger -t post-script "### (fence) stonith_dev=${stonith_dev}, pcmk_host_list=${pcmk_host}, port=${vm_name}"
		pcs stonith create ${stonith_dev} fence_xvm port=${vm_name} pcmk_host_list=${pcmk_host} op monitor interval=60s
		### kvm

		pcs constraint location ${stonith_dev} avoids ${pcmk_host}
	done
	logger -t post-script "### (fence) set stonith-enabled=true (on this node)"
	pcs property set stonith-enabled=true
else
	logger -t post-script "### (fence) (not on this node)"
fi
