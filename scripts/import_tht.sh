#!/bin/bash

set -x

#source ~/tripleo_configs/scripts/subr.sh
source ./subr.sh
release=RHOSP$(osp_version)
branch="${release}/THT"

tht_rpm=$(rpm -q openstack-tripleo-heat-templates)
tht_rpm_version=$(echo ${tht_rpm} | sed -e 's/^openstack-tripleo-heat-templates-//' -e 's/\.el7ost\.noarch$//')

echo "* release: ${release}"
echo "* tht_rpm: ${tht_rpm}"
echo "* tht_rpm_version: ${tht_rpm_version}"

mkdir -p tht
(cd /usr/share/openstack-tripleo-heat-templates && tar cf - .) | (cd tht && tar xvf -)
cp -r ./tht/network/config/bond-with-vlans nic-configs

git branch
git checkout -b ${branch}
git add tht nic-configs
#git push --set-upstream origin ${branch}
git commit -m "import THT from ${tht_rpm}, ${release}"
#git tag ${tht_rpm_version}
git tag ${tht_rpm}
#git push
