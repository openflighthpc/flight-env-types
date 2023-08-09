# apptainer(7) -- container solution for scientific and application driven workloads

## SYNOPSIS

Apptainer is an open-source container platform platform that has
been created to support high-performance computing (HPC) and research
workloads. First released in 2016, the container solution was created
by necessity for scientific and application driven workloads and aims
to support four primary functions:

  * Mobility of compute.
  * Reproducibility.
  * User freedom.
  * Support existing traditional HPC environments.

A user inside a Apptainer container is the same user as outside the
container. This is one of Apptainer's defining characteristics,
allowing a user (that may already have shell access to a particular
host) to simply run a command inside of a container image as
themselves.

For more details, please refer to the comprehensive Apptainer
documentation at <https://apptainer.org/docs>.

## ENVIRONMENT CREATION

This environment provides Apptainer v3.2.1. It is possible to create
either user-level Apptainer environments or, if you have write
access to the global environment tree, to create system-wide
Apptainer environments.

### Personal Environment

**NB. Personal Apptainer environments have several restrictions and,
as such, are experimental.** You may need to make requests to your
system administrators to perform operations that require superuser
access if your distribution does not contain support for [user
namespaces](http://man7.org/linux/man-pages/man7/user_namespaces.7.html). Most
modern Linux distributions do contain support, but it is not yet
universally enabled by default (notably CentOS 7.x does not yet enable
user namespaces by default).

If user namespaces are not enabled, you may receive an error such as:

```
ERROR  : Failed to create user namespace
```

To enable user namespace access (required to allow user-level access
to execute apptainer container instances), request that your system
administrator sets `/proc/sys/user/max_user_namespaces` to a
(non-zero) value high enough to allow for the quantity of simultaneous
Apptainer containers that will be executed on the host. We recommend
a value of `100`.

A personal Apptainer environment can be created using:

```
%PROGRAM_NAME% create apptainer
# ...or to create an environment named 'myenv':
%PROGRAM_NAME% create apptainer@myenv
```

This will configure a Apptainer installation and an, initially
empty, image cache environment.

Once created, activate your environment using:

```
%PROGRAM_NAME% activate apptainer
# ...or to activate the environment named 'myenv':
%PROGRAM_NAME% create apptainer@myenv
```

Use the `apptainer` command to perform image management for your
environment:

```
apptainer --help
```

To see what images are cached within your environment use the
`apptainer cache list` command; to execute a prebuilt image use
`apptainer run application.img`; to run a shell within an image use
`apptainer shell ...` and to build images use `apptainer build
...`.

Refer to the [Apptainer user
guide](https://apptainer.org/docs/user/latest) for more details.

### Global Environment

If you have write access to the global environment tree, a shared
Apptainer environment can be created using:

```
%PROGRAM_NAME% create --global apptainer
# ...or to create a environment named 'global':
%PROGRAM_NAME% create --global apptainer@global
```

This will configure a Apptainer installation and an, initially
empty, image cache environment.

Once created, the environment can be activated by any user using:

```
%PROGRAM_NAME% activate apptainer
# ...or to activate the environment named 'global':
%PROGRAM_NAME% activate apptainer@global
```

Note that only users who have write access to the global environment
tree are able to download upstream images to a shared environment.

If the environment was created by the superuser (root), then any user
may execute a cached or direct image, or run a shell within a cached or
direct image by using the `apptainer` command provided by the shared
environment.

Use the `apptainer` command to perform image management for your
environment:

```
apptainer --help
```

To see what images are cached within your environment use the
`apptainer cache list` command; to execute a prebuilt image use
`apptainer run application.img`; to run a shell within an image use
`apptainer shell ...` and to build images use `apptainer build
...`.

Refer to the [Apptainer user
guide](https://apptainer.org/docs/user/latest) for more details.

## LICENSE

This work is licensed under a Creative Commons Attribution-ShareAlike
4.0 International License.

See <http://creativecommons.org/licenses/by-sa/4.0/> for more
information.

## COPYRIGHT

Copyright (C) 2019-Present Alces Flight Ltd.
