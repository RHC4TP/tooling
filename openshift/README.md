## RHC4TP Tools for OpenShift

### `openshift_host_prep.sh`
This script is used to prepare a RHEL 7 based host to install OpenShift Container Platform, by performing the steps shown [here](https://docs.openshift.com/container-platform/latest/install/host_preparation.html). The script handles the following tasks for you:
* Registering the host with Subscription Manager
* Attaching an available OpenShift subscription
* Enabling required package repositories
* Updating the host
* Installing packages required for OpenShift
* Configuring docker to use the internal OpenShift registry
* Provisioning docker storage

#### Prerequisites
The following resources are required to run the script:
* Any number of RHEL 7 based hosts which will make up the OpenShift cluster
* OpenShift subscription for each host in the cluster.
* An empty/available block storage device for each host (for docker storage)
* All master hosts will need passwordless SSH access to all node hosts (covered in the host preparation link [here](https://docs.openshift.com/container-platform/latest/install/host_preparation.html#ensuring-host-access)

You may also need to update the `MAJOR` and `MINOR` versions of OpenShift (within the script) to match the version you are installing. These variables are set by default to the latest available version of OpenShift Container Platform (currently 3.10).

#### Installation
Just copy the script to each host member of the OpenShift cluster installation. It must be run with root permissions, and can be called with no arguments as shown:

 # sh openshift_host_prep.sh 

The script is interactive, and prompts for the following input:
* Red Hat account credentials to use for subscription manager
* Name of a block device (eg: /dev/sdb) to use for backing docker storage
* Last chance (are you sure?) prompt before erasing the named block device

When the script completes, you can move forward with installing OpenShift, which entails [building your Ansible Inventory](https://docs.openshift.com/container-platform/latest/install/configuring_inventory_file.html), and [launching the installation playbooks](https://docs.openshift.com/container-platform/latest/install/configuring_inventory_file.html). The RHC4TP team also has a blog post covering [OpenShift installation using Ansible](https://github.com/RHC4TP/blogs/blob/master/openshift-ansible/ocp-ansible-installer.adoc).

#### To Do
In the future, the script will support being run non-interactively (requiring no user input) for embedding into AWS user data, thus enabling seemless cloud deployments.

