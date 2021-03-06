#!/bin/bash

# OpenShift Container Platform host preparation script
# Author: Josh Manning and the Technical Team at Red Hat Connect for Technology Partners
#
# Copyright 2018 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# -- Environment Variables -- #
readonly OCP_MAJOR_VER=3 # Current Major Verion of OCP
readonly OCP_MINOR_VER=11 # Current Minor Version of OCP

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
fi

subscription-manager repos --disable=*

if [[ "${OCP_MAJOR_VER}${OCP_MINOR_VER}" -lt "311" ]]; then # No support for FP arithmetic in bash, so we concatenate the major & minor version strings together
	subscription-manager repos --enable=rhel-7-server{,-optional,-extras,-ose-$OCP_MAJOR_VER.$OCP_MINOR_VER,-ansible-2.4}-rpms --enable=rhel-7-fast-datapath-rpms
else
	subscription-manager repos --enable=rhel-7-server{,-optional,-extras,-ose-$OCP_MAJOR_VER.$OCP_MINOR_VER,-ansible-2.6}-rpms --enable=rhel-7-fast-datapath-rpms
fi

# -- Package Installation & Updates -- #
yum update -y
yum install -y docker git wget vim net-tools iptables-services bind-utils httpd-tools openshift-ansible

if [[ ! -e /usr/bin/docker ]]; then
	echo "ERROR: /usr/bin/docker does not exist. Exiting..."
	exit 16
fi

# -- Docker Daemon Config -- #
if [[ -a /etc/sysconfig/docker ]] && [[ -z $(grep insecure /etc/sysconfig/docker) ]]; then
	# The quotation mess below is necessary since the OPTIONS var in /etc/sysconfig/docker contains a single quoted string
	sed -i /etc/sysconfig/docker -e 's/^OPTIONS='"'"'\(.*\)/OPTIONS='"'"'--insecure-registry 172\.30\.0\.0\/16 \1/'
	# alternate w/same result
	# sed -i /etc/sysconfig/docker -e "s/OPTIONS='\\(.*\\)/OPTIONS='\\-\\-insecure\\-registry 172\\.30\\.0\\.0\\/16 \\1/"
fi

# -- Setup Docker Storage -- #
read -p "Please provide the path to your docker storage device [/dev/xvdf]: " DOCKER_STORAGE_DEVICE
DOCKER_STORAGE_DEVICE=${DOCKER_STORAGE_DEVICE:-/dev/xvdf}
echo "WARNING! All data on device ${DOCKER_STORAGE_DEVICE} will be destroyed!"
read -p "Are you sure you want to continue? [y/N]: " BRICK_ME

if [[ ${BRICK_ME} != [Yy] ]] && [[ ${BRICK_ME} != [Yy][Ee][Ss] ]]; then
	echo "You've chosen not to destroy data on ${DOCKER_STORAGE_DEVICE}. Exiting..."
	exit 4
fi

systemctl stop docker
rm -rf /var/lib/docker

# Starting with 3.10, the "/dev/" path prefix in /etc/sysconfig/docker-storage-setup is implied
if [[ "${OCP_MAJOR_VER}${OCP_MINOR_VER}" -lt "310" ]]; then 
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

echo "$(basename $0) setup concluded."
echo ""
echo "A host reboot is recommended, to allow any kernel updates to take effect."
exit 0
