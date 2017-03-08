#!/bin/bash

touch /root/touch_file

function add_user {
    user=$1; shift
    password=$1; shift
    ssh_pubkey=$1; shift

    logger -t post-script "### (user) create user: ${user}"
    useradd ${user}
    echo "${user}:${password}" | chpasswd
    #groupadd -g 1001 ${user}
    #useradd -d /home/${user} -g ${user} -G wheel -m -s /bin/bash -u 1001 ${user}
    #echo 'password' | passwd ${user} --stdin

    echo "${user} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${user}
    chmod 440 /etc/sudoers.d/${user}

    if [ x"$ssh_pubkey" != x"" ]; then
	mkdir -p /home/${user}/.ssh
	echo "${ssh_pubkey}" > /home/${user}/.ssh/authorized_keys
	chown -R ${user}:${user} /home/${user}/.ssh
	chmod 700 /home/${user}/.ssh
	chmod 600 /home/${user}/.ssh/authorized_keys
    fi
}

repo_file=local.repo
repo_host=debugs.nrt.redhat.com
repo_path=reposync/RHEL7/repos

## disable SELinux
#logger -t firstboot "### (selinux) disable SELinux"
#sed -i.orig -e 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
#setenforce 0

# rc.local
#logger -t firstboot "### (rc.local)"
#rclocal=/etc/rc.d/rc.local
#echo 'systemctl restart network' >> ${rclocal}  # rc.local hack for bz#1386299
#echo 'setterm -blank 0' >> ${rclocal} 
#chmod +x ${rclocal}

## root password
logger -t firstboot "### (root) set root password"
echo 'password' | sudo passwd root --stdin

## user/group
add_user ori ori

# ssh
sed -i -e 's/.*ssh-rsa/ssh-rsa/' /root/.ssh/authorized_keys
sed -i.orig -e 's/PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i -e 's/ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
sed -i -e 's/^#\(UseDNS .*$\)/UseDNS no/' /etc/ssh/sshd_config
systemctl restart sshd

## mkdir ${bindir}
bindir=/root/scripts
mkdir -p ${bindir}

## create tail.sh
echo "journalctl -fl | grep -Ev '((proxy|account|object|container)-server|haproxy|to rabbitmq|[Ss]ession.*rabbitmq|cinder-rootwrap|snmpd)'" > ${bindir}/tail.sh
chmod +x ${bindir}/tail.sh

## create die.sh
echo "date; echo c > /proc/sysrq-trigger" > ${bindir}/die.sh
chmod +x ${bindir}/die.sh

## watch1.sh
echo "watch -n 1 \"pcs status | sed '1,6d'\"" > ${bindir}/watch1.sh
chmod +x ${bindir}/watch1.sh

## watch2.sh
echo "watch -n 1 \"pcs status | tail -n 55\""> ${bindir}/watch2.sh
chmod +x ${bindir}/watch2.sh

## reboot.sh
echo "time pcs cluster stop; sleep 3; date; reboot"> ${bindir}/reboot.sh
chmod +x ${bindir}/reboot.sh

## service_status.sh
echo "watch -n 1 \"systemctl | grep -E 'httpd|neutron|openstack|mysql|maria|rabbit|haproxy|redis|mongo'\""> ${bindir}/service_status.sh
chmod +x ${bindir}/service_status.sh

### yum repository setup
## create local repo file
logger -t firstboot "### (rhel) create local repo file"
cat > /etc/yum.repos.d/${repo_file} <<END
[rhel-7-server-rpms]
name = rhel-7-server-rpms
baseurl = http://${repo_host}/${repo_path}/rhel-7-server-rpms
gpgcheck = 0
enabled = 1

[rhel-7-server-extras-rpms]
name = rhel-7-server-extras-rpms
baseurl = http://${repo_host}/${repo_path}/rhel-7-server-extras-rpms
gpgcheck = 0
enabled = 1

[rhel-7-server-openstack-10-rpms]
name = rhel-7-server-openstack-10-rpms
baseurl = http://${repo_host}/${repo_path}/rhel-7-server-openstack-10-rpms
gpgcheck = 0
enabled = 1

[rhel-7-server-openstack-10-optools-rpms]
name = rhel-7-server-openstack-10-optools-rpms
baseurl = http://${repo_host}/${repo_path}/rhel-7-server-openstack-10-optools-rpms
gpgcheck = 0
enabled = 1

[rhel-7-server-openstack-10-tools-rpms]
name = rhel-7-server-openstack-10-tools-rpms
baseurl = http://${repo_host}/${repo_path}/rhel-7-server-openstack-10-tools-rpms
gpgcheck = 0
enabled = 1

[rhel-7-server-openstack-10-devtools-rpms]
name = rhel-7-server-openstack-10-devtools-rpms
baseurl = http://${repo_host}/${repo_path}/rhel-7-server-openstack-10-devtools-rpms
gpgcheck = 0
enabled = 1

[rhel-7-server-rh-common-rpms]
name = rhel-7-server-rh-common-rpms
baseurl = http://${repo_host}/${repo_path}/rhel-7-server-rh-common-rpms
gpgcheck = 0
enabled = 1

[rhel-ha-for-rhel-7-server-rpms]
name = rhel-ha-for-rhel-7-server-rpms
baseurl = http://${repo_host}/${repo_path}/rhel-ha-for-rhel-7-server-rpms
gpgcheck = 0
enabled = 1
END

## disable Red Hat CDN
file=/etc/yum/pluginconf.d/subscription-manager.conf
test -f ${file}.orig || sed -i.orig -e 's/enabled=1/enabled=0/' ${file}
#file=/etc/yum.repos.d/redhat.repo
#test -f ${file} && mv ${file} ${file}_

### packages
#logger -t firstboot "### (rhel) update whole packages"
#yum update -y
#logger -t firstboot "### (rhel) install packages"
#yum install -y sysstat vim-enhanced strace lsof net-tools

### CTRL-ALT-DELETE
#ln -s /dev/null /etc/systemd/system/ctrl-alt-del.target
