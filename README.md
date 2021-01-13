# Docker Image hanlindong/opensees

This is an OpenSees docker image, built on [Alpine](https://www.alpinelinux.org/) Linux System.

NOTE: this repo is under development. There may be rapid changes.

## Features

The image size is very small. The `latest` tagged image is only 46.1 MB. It's easy to ship.

No configurations in the system is needed except for [docker](https://www.docker.com/) or [Kubernetes](https://kubernetes.io/). You don't have to configure TCL before using OpenSees. Any system that supports Docker or Kubernetes is able to run OpenSees, even in Raspberry Pi!

OpenSees scripts can be run in several ways. Type user scripts interactively, or compose a tcl script file. You can even create a `bash` command file to run multiple scripts with a single call.

Several OpenSees versions are provided. To run script on specific versions, just find the specified image tags.

See many more features in the [Tags](#Tags) section.

NOTE: The OpenSees python interpreter is not included in these images. To run a python interpreter, just use a python docker image, and pip install openseespy.

## Version

### latest

Alpine version: 3.12
Tcl version: 8.6.10
OpenSees version: 3.2.2, built with commit

Created on January 13, 2021.

### 3.2.0

Alpine version: 3.12
Tcl version: 8.6.10
OpenSees version: 3.2.0, built with commit 13a690b

Created on January 13, 2021.

### 3.1.0

Alpine version: 3.12
Tcl version: 8.6.10
OpenSees version: 3.1.0, build with commit

Created on January 13, 2021.

## Tags

`latest` `slim` `slim-3.2.0` `slim-3.1.0`: The minimized docker image to run OpenSees tcl interpreter.

`developer` `developer-3.2.0` `developer-3.1.0` : The source code are included in the image. Users can create their own routines to extend OpenSees. Only in this image is OpenSees compiled from source code. The compiled executable file is then copied to other images.

`jupyter` `jupyter-3.2.0` `jupyter-3.1.0` : Jupyter notebook is supported with minimal python packages.

`api` `api-3.2.0` `api-3.1.0` : API is created to run OpenSees. See [API](#API) section.

APIs are provided in the `api` tagged images. OpenSees can be called, and OpenSees scripts can be run by creating HTTP request.

OpenSees executable is compiled from the source code in the `developer` tagged images. The source code and DEVELOPER essential code are already included in these images. Developers can build dynamic linked files directly in the image. Then the developed dynamic linked files are available to all the co-workers.

## User guidelines

For docker users, install docker on your platform. See [https://docs.docker.com/install/](https://docs.docker.com/install/)

For K8s users, install K8s on your platform. See 

Then, Change directory (`cd`) to your working directory, where `.tcl` files are located

To run a `.tcl` file, type in your terminal:

```bash
docker run --rm -v $(pwd):/data hanlindong/opensees OpenSees xxxx.tcl
```

Note:

- `--rm`: remove the container after execution finishes.
- `-v`: mount your current directory (pwd) to /data (the default working space)
- `hanlindong/opensees`: this image. 
- `OpenSees xxxx.tcl`: your command.

You can also use bash scripts if you like:

```bash
docker run --rm -v $(pwd):/data hanlindong/opensees ./xxxx.sh
```

In this way, a bash script can be composed so that multiple scripts can be run at a single call. For example, create a file named `batch.sh`

```bash
mkdir logs
OpenSees script1.tcl > logs/script1.log 2>&1 &
OpenSees script2.tcl > logs/script2.log 2>&1 &
OpenSees script3.tcl > logs/script3.log 2>&1 &
```

And then, run

```bash
docker run --rm -v $(pwd):/data hanlindong/opensees ./batch.sh
```

The three scripts will run at once in the background.

If you want to run OpenSees interactively, type

```bash
docker run -it --rm -v $(pwd):/data hanlindong/opensees
```

Then, a interactive OpenSees interpreter will appear. Use it just like using locally.

Also, you can interact with bash in the docker image.

```bash
docker run -it --rm -v $(pwd):/data hanlindong/opensees bash
```

Now bash appears, and you can type commands just like in a Linux terminal.

## API

Under development.
