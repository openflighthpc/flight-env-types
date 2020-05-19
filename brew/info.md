# brew(7) -- The Missing Package Manager for macOS (or Linux)

## SYNOPSIS

The Homebrew package manager may be used on Linux and Windows
Subsystem for Linux (WSL). Homebrew was formerly referred to as
Linuxbrew when running on Linux or WSL. Homebrew does not
use any libraries provided by your host system, except glibc and gcc
if they are new enough. Homebrew can install its own current versions
of glibc and gcc for older distributions of Linux.

## ENVIRONMENT CREATION

This environment provides the latest available version of Homebrew. It
is possible to create either user-level Homebrew environments or, if
you have write access to the global environment tree, to create
system-wide Homebrew environments.

### Personal Environment

A personal Homebrew environment can be created using:

```
%PROGRAM_NAME% create brew
# ...or to create an environment named 'myenv':
%PROGRAM_NAME% create brew@myenv
```

This will configure a minimal Homebrew environment configured with the
`brew` command for managing package installations.

Once created, activate your environment using:

```
%PROGRAM_NAME% activate brew
# ...or to activate the environment named 'myenv':
%PROGRAM_NAME% create brew@myenv
```

Use the `brew` command to perform package management for your
environment:

```
brew --help
```

Refer to the [Homebrew documentation](https://docs.brew.sh/)
for more details.

### Global Environment

If you have write access to the global environment tree, a shared
Homebrew environment can be created using:

```
%PROGRAM_NAME% create --global brew
# ...or to create a environment named 'global':
%PROGRAM_NAME% create --global brew@global
```

This will configure a minimal Homebrew environment configured with the
`brew` command for managing package installations.

Once created, activate your environment using:

```
%PROGRAM_NAME% activate brew
# ...or to activate the environment named 'global':
%PROGRAM_NAME% create brew@global
```

Note that only users who have write access to the global environment
tree are able to install packages to a shared environment, though any
user may use installed packages.

Use the `brew` command to perform package management for your
environment:

```
brew --help
```

Refer to the [Homebrew documentation](https://docs.brew.sh/)
for more details.

## LICENSE

This work is licensed under a Creative Commons Attribution-ShareAlike
4.0 International License.

See <http://creativecommons.org/licenses/by-sa/4.0/> for more
information.

## COPYRIGHT

Copyright (C) 2020-Present Alces Flight Ltd.
