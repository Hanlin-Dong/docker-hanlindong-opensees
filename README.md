# Docker Image hanlindong/opensees

This is an awesome OpenSees docker image, built on [Alpine](https://www.alpinelinux.org/) Linux System.

## Features
The image size is very small, so it's easy to move.

You can run OpenSees or bash in the container.

## Version

**Latest version:**

Tcl version: 8.6.10

OpenSees version: 3.2.0, built on github repository commit 13a690bee050e1237bb268b4d7070bc31da9b48e

**Other versions:**

2.5.0-r6258

## User guidelines:

First, install docker on your platform. See https://docs.docker.com/install/

Then, Change directory (`cd`) to your working directory, where `.tcl` files are located

To run a `.tcl` file, type in your terminal:

    docker run --rm -v $(pwd):/data hanlindong/opensees OpenSees xxxx.tcl

Note:
* `--rm`: remove the container after execution finishes.
* `-v`: mount your current directory (pwd) to /data (the default working space)
* `hanlindong/opensees`: this image. 
* `OpenSees xxxx.tcl`: your command.
      
You can also use bash scripts if you like:

    docker run --rm -v $(pwd):/data hanlindong/opensees ./xxxx.sh
        
If you want to run OpenSees interactively, type

    docker run -it --rm -v $(pwd):/data hanlindong/opensees

Now, please enjoy :)
