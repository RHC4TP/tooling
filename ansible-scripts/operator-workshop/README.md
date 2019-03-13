# About

This repository installs all of the prerequisite software needed to start developing an Operator using the SDK on your local machine.

Software installed:

* [Golang](https://golang.org/doc/install) v1.11.5
* [Dep](https://github.com/golang/dep) v0.5.1
* [MiniShift](https://docs.okd.io/latest/minishift/getting-started/installing.html) v1.32
* [OpenShift client](https://docs.okd.io/latest/cli_reference/get_started_cli.html) v3.11.0
* [Operator-SDK](https://github.com/operator-framework/operator-sdk) v0.5.0
* [Docker](https://docs.docker.com/install/) v18.09.3

> This has only been tested on a fresh install of Fedora 29.

# Usage

Ansible must be installed on your local machine for this to work. Follow the steps below to get started:

> **IMPORTANT:** do **not** run playbook as `root` user. This installation will configure everything for the {{ ansible_user_id }} running the playbook (this is your user account!).

```bash
$ git clone https://github.com/RHC4TP/tooling.git
$ cd tooling/ansible-scripts/operator-workshop
$ ansible-playbook --ask-sudo-pass operator-workshop-install.yml
```

When the playbook is done, it is **highly recommended** that you restart your machine. Restarting your machine will reload your shell session to recognize the new installations and is also a good way to test that the services enabled are working. If you cannot restart your machine, you **must** at least reload your shell session by running the `exec $SHELL` command.

# Test Your Installation

```bash
$ go version
# output
go version go1.11.5 linux/amd64

$ dep version
# output
dep:
 version     : v0.5.1
 build date  : 2019-03-11
 git hash    : faa6189
 go version  : go1.12
 go compiler : gc
 platform    : linux/amd64
 features    : ImportDuringSolve=false


 $ minishift version
 # output
 minishift v1.32.0+009893b


 $ oc version
 # output
 oc v3.11.0+0cbc58b
 kubernetes v1.11.0+d4cacc0
 features: Basic-Auth GSSAPI Kerberos SPNEGO

 $ operator-sdk --version
 # output
 operator-sdk version v0.5.0+git

 $ docker version
 # output
  Client:
   Version:           18.09.3
   API version:       1.39
   Go version:        go1.10.8
   Git commit:        774a1f4
   Built:             Thu Feb 28 06:34:10 2019
   OS/Arch:           linux/amd64
   Experimental:      false

```

# Build Your First Operator

Create and deploy an app-operator using the SDK CLI. Make sure your MiniShift cluster is running prior to completing these steps.

```bash
# Create an app-operator project that defines the App CR.
$ mkdir -p $GOPATH/src/github.com/example-inc/
# Create a new app-operator project
$ cd $GOPATH/src/github.com/example-inc/
$ operator-sdk new app-operator
$ cd app-operator

# Add a new API for the custom resource AppService
$ operator-sdk add api --api-version=app.example.com/v1alpha1 --kind=AppService

# Add a new controller that watches for AppService
$ operator-sdk add controller --api-version=app.example.com/v1alpha1 --kind=AppService

# Build and push the app-operator image to a public registry such as quay.io
$ operator-sdk build quay.io/example/app-operator
$ docker push quay.io/example/app-operator

# Update the operator manifest to use the built image name (if you are performing these steps on OSX, see note below)
$ sed -i 's|REPLACE_IMAGE|quay.io/example/app-operator|g' deploy/operator.yaml
# On OSX use:
$ sed -i "" 's|REPLACE_IMAGE|quay.io/example/app-operator|g' deploy/operator.yaml

# Setup Service Account
$ oc create -f deploy/service_account.yaml
# Setup RBAC
$ oc create -f deploy/role.yaml
$ oc create -f deploy/role_binding.yaml
# Setup the CRD
$ oc create -f deploy/crds/app_v1alpha1_appservice_crd.yaml
# Deploy the app-operator
$ oc create -f deploy/operator.yaml

# Create an AppService CR
# The default controller will watch for AppService objects and create a pod for each CR
$ oc create -f deploy/crds/app_v1alpha1_appservice_cr.yaml

# Verify that a pod is created
$ oc get pod -l app=example-appservice
NAME                     READY     STATUS    RESTARTS   AGE
example-appservice-pod   1/1       Running   0          1m

# Test the new Resource Type
$ oc describe appservice example-appservice
Name:         example-appservice
Namespace:    myproject
Labels:       <none>
Annotations:  <none>
API Version:  app.example.com/v1alpha1
Kind:         AppService
Metadata:
  Cluster Name:        
  Creation Timestamp:  2018-12-17T21:18:43Z
  Generation:          1
  Resource Version:    248412
  Self Link:           /apis/app.example.com/v1alpha1/namespaces/myproject/appservices/example-appservice
  UID:                 554f301f-0241-11e9-b551-080027c7d133
Spec:
  Size:  3

# Cleanup
$ oc delete -f deploy/crds/app_v1alpha1_appservice_cr.yaml
$ oc delete -f deploy/operator.yaml
$ oc delete -f deploy/role.yaml
$ oc delete -f deploy/role_binding.yaml
$ oc delete -f deploy/service_account.yaml
$ oc delete -f deploy/crds/app_v1alpha1_appservice_crd.yaml
```

# Resources

To get started with building operators it is recommended that you go through these exercises:

* [Kubernetes Introduction](https://www.katacoda.com/courses/kubernetes)
* [Learn OpenShift](https://learn.openshift.com/)
* [Ansible Operator](https://learn.openshift.com/ansibleop)
* [Ansible Operator Overview](https://learn.openshift.com/ansibleop/ansible-operator-overview/)
* [Official Operator SDK](https://github.com/operator-framework/operator-sdk)


### To Do
* Add more conditions for different operating systems.
