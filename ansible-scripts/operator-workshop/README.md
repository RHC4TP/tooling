# About

This repository installs all of the prerequisite software needed to start developing an Operator using the SDK on your local machine.

Software installed:

* Golang
* Dep
* MiniShift
* OpenShift client
* Operator-SDK
* Docker

> This has only been tested on a fresh install of Fedora 29.

# Useage

Ansible must be installed on your local machine for this to work. Follow the steps below to get started:

> **IMPORTANT:** do **not** run playbook as `root` user.

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

# Resources

To get started with building operators it is recommended that you go through these exercises:

* [Kubernetes Introduction](https://www.katacoda.com/courses/kubernetes)
* [Learn OpenShift](https://learn.openshift.com/)
* [Ansible Operator](https://learn.openshift.com/ansibleop)
* [Ansible Operator Overview](https://learn.openshift.com/ansibleop/ansible-operator-overview/)


### To Do
* Add more conditions for different operating systems.
