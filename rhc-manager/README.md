Red Hat Container Manager
=========================

This program allows you to retrieve information about the container project from Red Hat Connect and trigger manual builds without needing to log into the website.

## Requirements

- [Docker](https://www.docker.com/get-started)
- Build service **must** be enabled for your project prior to running these commands for this to work.

## Usage

All you have to do clone this repository, run the docker container, and run the bash commands. Having Ruby installed on your machine is not necessary.

#### Steps

1. `git clone git@github.com:RHC4TP/tooling.git`
2. `cd rhc-manager`
3. `docker build -t rhc-manager .`
4. `docker run -it --rm rhc-manager` #This will begin a new shell session inside the container.
5. Use the commands below within the docker session.

Get project info:

```sh
./rhc_cli -i <project_id>
```

Trigger manual build:

```sh
./rhc_cli -i <project_id> -t <build_tag>
```

### To Do

* Add an error when the response times out.
* Check if API is down.
* Dockerize script.
* Add tests and validations.
