# About

This repository installs all of the prerequisite software needed to build an Operator.
* Golang
* Dep
* MiniShift (along with virtualization dependencies)
* oc client (to be completed)
* Operator-SDK
* Docker

# Useage

Ansible must be installed on your local machine. Once installed, just clone this repo and run the command below:

**IMPORTANT:** do not run playbook as `root` user.

```bash
$ ansible-playbook --ask-sudo-pass operator-workshop-install.yml
```

Once successfully complete, open a new terminal session or reload your shell:
`source ~/.bashrc` or `source ~/.zshrc` if you're using zsh.

Check that `GOPATH` is set correctly with this command:

```bash
$ go env GOPATH
/home/user/go
```

Please note that Ansible will still keep your old .bashrc or .zshrc file backed up in your `$HOME` directory in case you want to revert back to your old configuration.

# Test Your Installation

Check that Go is installed correctly by setting up a workspace and building a simple program, as follows.

```bash
package main

import "fmt"

func main() {
      fmt.Printf("hello, world\n")
}
```

Then build it with the go tool:

```bash
$ cd $HOME/go/src/hello
$ go build
```

The command above will build an executable named hello in the directory alongside your source code. Execute it to see the greeting:

```bash
$ ./hello
hello, world
```

If you see the "hello, world" message then your Go installation is working.

You can run go install to install the binary into your workspace's bin directory or go clean -i to remove it.



### To Do
* Add more conditions for different OS.
