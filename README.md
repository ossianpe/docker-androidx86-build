# docker-androidx86-build

This repo contains docker images used for building Androidx86/BlissOSx86 roms. The advantage of these scripts are that the entire build environment is modularized into a container--while the repo and build artifacts are stored in the native filesystem.

# Setup
## Configuration

Before running the script, please be sure to set the following parameters in the script:

```
SOURCE_BUILD_DIR     (absolute path of where to store repo)
DOCKER_REG           (personal or public docker registry name)
```

## Instantiation 

Run `./build.sh`. The following parameters are available for use:

```
-a      Specify Android version (default is pie)
-b      Specify a BlissOSx86 build (default is Androidx86)
-k      Specify a kernel version to build (default is 4.9)
```

# Building the Docker images

Once the Docker images have been built, run them with the command that is printed to the screen. In my case the command is:

```
docker run --mount type=bind,src=/mnt/source-code/androidx86/bliss/pie,dst=/androidx86 -it docreg.local:5000/bliss_builder:pie_android_x86_64 /bin/bash
```

Once inside the Docker container run:

```
./init.sh
cd /androidx86
```

# Building an Android/BlissOS x86 image

To start a build once inside the container (and having executed prior steps) run:

```
cmds/make_image.sh
```

## Switching kernel

Additionally, to change the kernel the following command can be executed:

```
cmds/make_kernel.sh <kernel_version>
```

To determine the `<kernel_version>`. See the branch names for the `kernel`. This can be done with the following script:

```
cmds/list_kernels.sh
```