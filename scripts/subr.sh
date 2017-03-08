#!/bin/bash

function upper_path {
	local path=$1; shift
	echo ${path%/*}
}

function absolute_path {
	local script_path=$1; shift
	echo $(cd $(dirname ${script_path}) && pwd)/$(basename ${script_path})
}

function osp_version {
	pkgname=$(rpm -q rhosp-director-images 2> /dev/null)
	if [ x"$?" = x"0" ]; then
		osp_version=$(echo ${pkgname} | sed -e 's/^rhosp-director-images-//' -e 's/-[0-9.]\+el[0-9]ost.noarch//')
		echo ${osp_version} | sed -e 's/\.0$//'
	else
		nova_version=$(rpm -q openstack-nova-api | sed -e 's/openstack-nova-api-//' -e 's/-[0-9.]\+el[0-9]ost.noarch//')
		case ${nova_version} in
		2013.2.*)
			# RHOSP4: openstack-nova-api-2013.2.3-12.el6ost.noarch
			echo 4
			;;
		2014.1.*)
			# RHOSP5: openstack-nova-api-2014.1.5-31.el6ost.noarch
			echo 5
			;;
		2014.2.*)
			# RHOSP6: openstack-nova-api-2014.2.3-75.el7ost.noarch
			echo 6
			;;
		2015.1.*)
			# RHOSP7: openstack-nova-api-2015.1.2-13.el7ost.noarch
			echo 7
			;;
		12.*)
			# RHOSP8: openstack-nova-api-12.0.4-16.el7ost.noarch
			echo 8
			;;
		13.*)
			# RHOSP9: openstack-nova-api-13.1.2-9.el7ost.noarch
			echo 9
			;;
		14.*)
			# RHOSP10: openstack-nova-api-14.0.2-7.el7ost.noarch
			echo 10
			;;
		*)
			echo "Unknown nova-api version: ${nova_version}"
			;;
		esac
	fi
}

function openstack_release {
	local osp_version=$1; shift
	case ${osp_version} in
	4)
		echo "Havana"
		;;
	5)
		echo "Icehouse"
		;;
	6)
		echo "Juno"
		;;
	7)
		echo "Kilo"
		;;
	8)
		echo "Liberty"
		;;
	9)
		echo "Mitaka"
		;;
	10)
		echo "Newton"
		;;
	11)
		echo "Ocata"
		;;
	12)
		echo "Pike"
		;;
	13)
		echo "Queen"
		;;
	*)
		echo "Unknown OpenStack version for ${osp_version}"
		;;
	esac
}

function test {
	osp_version=$(osp_version)
	openstack_release=$(openstack_release ${osp_version})
	echo "* abspath = ${abspath}"
	echo "* bindir = ${bindir}"
	echo "* topdir = ${topdir}"
	echo "* osp_version = ${osp_version}"
	echo "* openstack_release = ${openstack_release}"
}

abspath=`absolute_path $0`
bindir=`dirname ${abspath}`
topdir=`upper_path ${bindir}`

#test
