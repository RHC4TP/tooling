Red Hat Container Manager
=========================

This program allows you to retrieve information about the container project from Red Hat Connect and trigger manual builds without needing to log into the website.

## Requirements

- [Ruby](https://www.ruby-lang.org/en/documentation/installation/)
- Build service **must** be enabled for your project prior to running these commands for this to work.

## Usage

You can find out if ruby is installed by running:  `which ruby`. If you have ruby installed, then proceed.

1. `git clone git@github.com:RHC4TP/tooling.git`
2. `cd rhc-manager`
3. `bundle install`

Get project info:

```sh
./rhc_cli -id <project_id>
```

Trigger manual build:

```sh
./rhc_cli -id <project_id> -b <build_tag>
```

### To Do

* Add an error when the response times out.
* Check if API is down.
* Dockerize script
* Add tests and validations
