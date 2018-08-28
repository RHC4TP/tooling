#!/bin/bash

## OpenShift Container Platform host preparation script
## Author: Josh Manning and the RHC4TP Technical Team
## Version: 20180810

# -- Environment Variables -- #
readonly OCP_MAJOR_VER=3 # Current Major Verion of OCP
readonly OCP_MINOR_VER=10 # Current Minor Version of OCP

# -- Check Root Privileges -- #
if [[ $(whoami) != root ]]; then
	"This script must be run with root privileges. Exiting..."
	exit 1
fi
	
# -- Subscription Manager -- #
subscription-manager register
SM_EXIT=$? # subscription-manager exit code
if [[ ${SM_EXIT} != 0 ]] && [[ ${SM_EXIT} != 64 ]]; then # if not either successfully registered (0) or already registered (64)
	echo "Failed to register. Exiting..."
	exit 2
fi
if [[ -z $(subscription-manager list --consumed | grep '^Subscription Name: \+Red Hat OpenShift.*') ]]; then
	POOL=$(subscription-manager list --available | grep -A 10 OpenShift | grep Pool | tail -1 | awk -F ':' '{ print $2 }' | sed 's/^\s\+//') # Get available subs | show 10 lines after each match of OpenShift | fetch lines with Pool ID | show only 1 line | print second field after the ':' (pool id number) | strip leading whitespace
	subscription-manager attach --pool=${POOL}
	subscription-manager repos --enable=rhel-7-server{,-optional,-extras,-ose-$OCP_MAJOR_VER.$OCP_MINOR_VER,-ansible-2.4}-rpms --enable=rhel-7-fast-datapath-rpms
	OLD_REPOS=$(subscription-manager repos --list-enabled | grep '3\.\?' | grep -v "${OCP_MAJOR_VER}\.${OCP_MINOR_VER}" | grep ID | awk -F ':' '{print $2}' | sed 's/^\s\+//') # Assemble list of outdated OSE repos
	if [[ -n $OLD_REPOS ]]; then # loop to disable outdated OSE repos
		for i in $OLD_REPOS; do
		subscription-manager repos --disable=$i
		done
	fi
fi

# -- Package Installation & Updates -- #
yum update -y
yum install -y docker git wget vim net-tools iptables-services bind-utils httpd-tools openshift-ansible

# -- Docker Daemon Config -- #
if [[ -a /etc/sysconfig/docker ]] && [[ -z $(grep insecure /etc/sysconfig/docker) ]]; then
	# The quotation mess below is necessary since the OPTIONS var in /etc/sysconfig/docker contains a single quoted string
	sed -i /etc/sysconfig/docker -e 's/^OPTIONS='"'"'\(.*\)/OPTIONS='"'"'--insecure-registry 172\.30\.0\.0\/16 \1/'
	# alternate w/same result
	# sed -i /etc/sysconfig/docker -e "s/OPTIONS='\\(.*\\)/OPTIONS='\\-\\-insecure\\-registry 172\\.30\\.0\\.0\\/16 \\1/"
fi

# -- Setup Docker Storage -- #
read -p "Please provide the path to your docker storage device [/dev/vdb]: " DOCKER_STORAGE_DEVICE
DOCKER_STORAGE_DEVICE=${DOCKER_STORAGE_DEVICE:-/dev/vdb}
echo "WARNING! All data on device ${DOCKER_STORAGE_DEVICE} will be destroyed!"
read -p "Are you sure you want to continue? [y/N]: " BRICK_ME
if [[ ${BRICK_ME} != [Yy] ]] && [[ ${BRICK_ME} != [Yy][Ee][Ss] ]]; then
	echo "You've chosen not to destroy data on ${DOCKER_STORAGE_DEVICE}. Exiting..."
	exit 4
fi
systemctl stop docker
rm -rf /var/lib/docker

# Starting with 3.10, the "/dev/" path prefix in /etc/sysconfig/docker-storage-setup is implied
if [[ "${OCP_MAJOR_VER}${OCP_MINOR_VER}" -lt "310" ]]; then # No support for FP arithmetic in bash, so we concatenate the major/minor version strings, and run the following code only for versions older than 310
	echo "DEVS=${DOCKER_STORAGE_DEVICE}" > /etc/sysconfig/docker-storage-setup
	echo "VG=docker-vg" >> /etc/sysconfig/docker-storage-setup
else
	echo "STORAGE_DRIVER=overlay2" > /etc/sysconfig/docker-storage-setup
	echo "DEVS=${DOCKER_STORAGE_DEVICE}" | sed -e 's,/dev/,,' >> /etc/sysconfig/docker-storage-setup # for newer versions of OCP, strip the '/dev/' prefix when writing to /etc/sysconfig/docker-storage-setup
	echo "VG=docker-vg" >> /etc/sysconfig/docker-storage-setup
fi
rm -rf /var/lib/docker
lvremove docker-vg -f
vgremove docker-vg
dd if=/dev/zero of=${DOCKER_STORAGE_DEVICE} bs=1024 count=1
>/etc/sysconfig/docker-storage
docker-storage-setup

# -- Start/Enable Docker -- #
systemctl start docker
if [[ $? != 0 ]]; then
	echo "Docker failed to start. Exiting..."
	exit 8
fi
systemctl enable docker

