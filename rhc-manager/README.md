Red Hat Container Manager
=========================

This program allows you to retrieve information about the container project from Red Hat Connect and trigger manual builds without needing to log into the website.

## Requirements

- [Docker](https://www.docker.com/get-started)
- Build service **must** be enabled for your project prior to running these commands for this to work.

## Usage

All you have to do clone this repository, build the container, run the container, and run the bash commands. Having Ruby installed on your machine is not necessary.

#### Steps

1. `git clone git@github.com:RHC4TP/tooling.git`
2. `cd rhc-manager`
3. `docker build -t rhc-manager .`
4. `docker run -it --rm rhc-manager` #This will begin a new shell session inside the container.
5. Use the commands below within the docker session.

Get Project Info:

```sh
./rhc_cli.rb -i <project_id>
```
![Get Request](https://media.giphy.com/media/4JXVgM3LOW4rMf2CcY/giphy.gif)

Trigger Manual Build:

```sh
./rhc_cli.rb -i <project_id> -t <build_tag>
```
![Post Request](https://media.giphy.com/media/Wv7enVd7i4IqNwsHHj/giphy.gif)

### Note:
You only need to build the docker container the first time after cloning. To trigger more builds or get more data, just run the `docker run -it --rm rhc-manager` again and then the appropriate commands.

#### How To Find Your Project ID
Your project ID can be found in the "Upload Your Image" tab on the main page of your project. Scroll to the bottom where it says "Push Your Container" and you will find a `docker push` command similar to this: `docker push scan.connect.redhat.com/ospid-3aeb2x96-8c59-4ea7-3dc8-c50481fb49c9/[image-name]:[tag]`. The long string starting with ospid or sometimes pid is your project ID.

### To Do

* Add an error when the response times out.
* Check if API is down.
* Dockerize script.
* Add tests and validations.
