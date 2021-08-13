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

### latest 3.3.0

Alpine version: 3.12
Tcl version: 8.6.10
OpenSees version: 3.3.0, built with commit

Created on August 13, 2021.

### 3.2.2

Alpine version: 3.12
Tcl version: 8.6.10
OpenSees version: 3.2.2, built with commit 5c925e6

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

`latest` `v3.3.0` `slim` `slim-v3.3.0`: The minimized docker image to run OpenSees tcl interpreter.

`developer` `developer-v3.3.0`: The source code are included in the image. Users can create their own routines to extend OpenSees. Only in this image is OpenSees compiled from source code. The compiled executable file is then copied to other images.

`jupyter` `jupyter-v3.3.0`: Jupyter notebook is supported with minimal python packages.

(Under development) `api` : API is created to run OpenSees. See [API](#API) section.

APIs are provided in the `api` tagged images. OpenSees can be called, and OpenSees scripts can be run by creating HTTP request.

`doweltype` `doweltype-v3.3.0` : OpenSees is extended with a newly developed hysteretic model for dowel-type timber joints named DowelType. The documentation see [https://github.com/Hanlin-Dong/DowelType-OpenSees](https://github.com/Hanlin-Dong/DowelType-OpenSees). Reference:

> Hanlin Dong, Minjuan He, Xijun Wang, Constantin Christopoulos, Zheng Li, Zhan Shu. Development of a uniaxial hysteretic model for dowel-type timber joints in OpenSees. *Construction and Building Materials*, 288(2021), 123112. <https://doi.org/10.1016/j.conbuildmat.2021.123112>

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

The image tagged `API` provides several APIs to call OpenSees. It is implemented with Flask and Gunicorn.

> The API images are still under development. Pull request or create an issue for feature request.

### Run pure script 

Runs a single pure tcl script. `stdout` and `stderr` are returned. The welcome banner from stderr is removed. The script must be finished within 60 seconds. Otherwise, error will be triggered.

- URL: http://localhost:9889/script
- METHOD: POST
- URL PARAMS: None
- DATA PARAMS: 
  - script: string, the command.
- SUCCESS:
  - Code: 200, success
  - Content: 
    - stdout: stdout
    - stderr: stderr (Most OpenSees results are in stderr)
- ERROR:
  - Code: 400, bad request
    Content: "error": string, reason of bad request.
  - Code: 408, request timeout
    Content: "error": string, reason of request timeout.
- SAMPLE:

```http
POST http://127.0.0.1:9889/script
Content-Type: application/json

{
    "script": "model BasicBuilder -ndm 1 -ndf 1\nnode 1 0.0\nprint -node 1"
}
```

RESPONSE:

```json
{
  "stderr": "\n Node: 1\n\tCoordinates  : 0 \n\n",
  "stdout": ""
}
```

### Run a single file

This API runs a file in the container. The file folder should be mounted to `/data` so that it is readable by the container. Other scripts that are `source`ed to the script file can also be read. No time expiration is set.

If the recorder data is to be returned, POST method should be used. Provide the recorder name and the recorder results will be read and returned as a column-first two-dimensional float array.

- URL: http://127.0.0.1:9889/file/<filename>
- METHOD: GET, POST
- URL PARAMS: None
- DATA PARAMS: 
  - recorders: List of filenames. The recorded filenames will be returned.
- SUCCESS:
  - Code: 200
  - Content: 
    - stdout: stdout
    - stderr: stderr (Most OpenSees results are in stderr)
    - columns: list of strings, recorder name followed with column number.
    - values: list of list of numbers. Data from the recorders.
- ERROR:
  - Code: 404
  - Content: {"error": "File is not found."}
- SAMPLE:

In `simple_truss.tcl`

```tcl
model BasicBuilder -ndm 2 -ndf 2
node 1 0. 0.
node 2 0. 1.
node 3 1. 0. -mass 1. 1.
fix 1 1 1
fix 2 1 1
uniaxialMaterial Elastic 1 1.0
element Truss 1 1 3 100. 1
element Truss 2 2 3 100. 1
recorder Node -file node3.out -node 3 -dof 1 2 eigen1
puts [eigen -fullGenLapack 1]
record
```

Sample 1: GET

```HTTP
GET http://localhost:9889/file/simple_truss.tcl
```

RESPONSE:

```json
{
  "output": "            24.11809548974792249965  \n"
}
```

Sample 2: POST

```HTTP
POST http://localhost:9889/file/simple_truss.tcl
Content-Type: application/json

{
    "recorders": ["node3.out"]
}
```

Sample 3: POST

```HTTP
POST http://localhost:9889/project
Content-Type: application/json

{
    "files": [
        {
            "path": "",
            "name": "script.tcl",
            "content": ""
        },
        {
            "path": "",
            "name": "",
            "filename": "ops2yaml.tcl"
        }
    ],
    "entry": "script.tcl",
    "script": "sdgasdg",
    "recorders": ["node3.out"]
}
```

RESPONSE:

```json
{
  "data": {
    "node3.out": [
      [
        0.317837
      ],
      [
        1.0
      ]
    ]
  },
  "output": "            24.11809548974792249965  \n"
}
```

## Get geometry

- URL: http://127.0.0.1:9889/geometry
- METHOD: POST
- URL PARAMS: None
- DATA PARAMS:
  - script: the OpenSees script.
- SUCCESS:
  - Code: 200
  - Content:
    - output: the output from console.
    - nodes: the node properties in the model.
    - elements: the elements in the model.
- ERROR:
  - Code: 404
  - Content: {"error": "File is not found."}
- SAMPLE:

## Get eigen value and vectors

Get the eigen value and vectors from a script.

## Test uniaxial material

Test material hystereses

## Test section

Test section hystereses

```api
GET http://localhost:9889/runfile/<filename>
```

Run the file in `/data` folder with filename. The results are also included in the `/data` folder. Users should mount their own directory to `/data` when creating docker container. E.g. use `-v $(pwd):/data` to mount the current working directory.

```api
POST http://localhost:9889/runscript
```

POST a request contains the following fields

```json
{
    "script": [
        "model BasicBuilder -ndm 3 -ndf 6",
        "node 1 0.0 0.0 0.0",
        "print -node 1"
    ],
    "externalScripts": [
        "opensees2yaml.tcl",
        "rayleighdamping.tcl",
    ],
    "readFiles": [
        "recorder1.out"
    ]
}
```

The console outputs will be returned as well as the recorder files specified in "readFiles" field.

```json
{
    "success": true,
    "reason": null,
    "stderr": "...",
    "stdout": "...",
    "readFiles": [
        {
            "filename": "recorder1.out",
            "content": [[], []],
        }
    ]
}
```

Note that the APIs are **not safe**. Users can use commands like `source`, `file` etc. Use at your own risk.

## Update history

### August 13, 2021

Upgrade to OpenSees v3.3.0 

The automatic build for dockerhub is no longer available for free users. Therefore the images are built on my local machine.  

The tags are pruned.

### Initiate

This repo is major updated in January 13, 2021. The tags are re-organized. All the images except `developer` tagged use pre-compiled OpenSees executable file instead of compiling. Tcl interpreter and some python packages are also installed via Alpine package manager `apk` instead of compiling from source. This results the images are smaller and more robust.
