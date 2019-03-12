# About

Most modern languages can easily be installed via a package manager with no further configuration, however, Golang is a bit different. After installing Golang it is required that you set custom variables in your shell. Depending on your user and shell, your installation may vary. The goal of this script is to identify your user, OS, and default shell to bootstrap your Golang installation.

# What This Does

1. Installs the latest version of Golang.
2. Creates `$HOME/go`, `$HOME/go/bin`, `$HOME/go/pkg`, and `$HOME/go/src` directories.
3. Adds exports to your `.bashrc` or `.zshrc` to prevent `PATH` errors for future projects.

# Useage

Ansible must be installed on your local machine. Once installed, just clone this repo and run the command below:

**IMPORTANT:** do not run playbook as `root` user.

`$ ansible-playbook main.yml`

Once successfully complete, open a new terminal session or reload your shell:
`source ~/.bashrc` or `source ~/.zshrc` if you're using zsh.

Check that `GOPATH` is set correctly with this command:
```
$ go env GOPATH
/home/user/go
```

Please note that Ansible will still keep your old .bashrc or .zshrc file backed up in your `$HOME` directory in case you want to revert back to your old configuration.

# Test Your Installation

Check that Go is installed correctly by setting up a workspace and building a simple program, as follows.

```
package main

import "fmt"

func main() {
      fmt.Printf("hello, world\n")
}
```

Then build it with the go tool:

```
$ cd $HOME/go/src/hello
$ go build
```

The command above will build an executable named hello in the directory alongside your source code. Execute it to see the greeting:

```
$ ./hello
hello, world
```

If you see the "hello, world" message then your Go installation is working.

You can run go install to install the binary into your workspace's bin directory or go clean -i to remove it.



### To Do
* Reload shell when Ansible script is complete
* Add more conditions for different OS.
* Create roles
