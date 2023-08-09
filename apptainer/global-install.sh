#!/bin/bash
# =============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Environment.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Environment is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Environment. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Environment, please visit:
# https://github.com/openflighthpc/flight-env
# ==============================================================================
set -e

flight_ENV_ROOT=${flight_ENV_ROOT:-${flight_ROOT}/var/lib/env}
flight_ENV_CACHE=${flight_ENV_CACHE:-${flight_ROOT}/var/cache/env}
flight_ENV_BUILD_CACHE=${flight_ENV_BUILD_CACHE:-${flight_ROOT}/var/cache/env/build}
name=$1

if [ -z "$name" ]; then
  echo "error: environment name not supplied"
  exit 1
fi

# create directory structure
mkdir -p ${flight_ENV_CACHE} ${flight_ENV_BUILD_CACHE} ${flight_ENV_ROOT}
cd ${flight_ENV_BUILD_CACHE}

# XXX - verify that /proc/sys/user/max_user_namespaces is greater than 0

env_stage "Verifying prerequisites"
SQUASHFS_VER=4.6.1
GO_VER=1.20.7
APPTAINER_VER=1.2.2
if [ ! -f squashfs-${SQUASHFS_VER}.tar.gz ]; then
  env_stage "Fetching prerequisite (squashfs)"
  wget -O squashfs-${SQUASHFS_VER}.tar.gz https://github.com/plougher/squashfs-tools/archive/refs/tags/${SQUASHFS_VER}.tar.gz
  env_stage "Extracting prerequisite (squashfs)"
  tar xzf squashfs-${SQUASHFS_VER}.tar.gz
  env_stage "Building prerequisite (squashfs)"
  cd squashfs-tools-${SQUASHFS_VER}/squashfs-tools
  make
  env_stage "Installing prerequisite (squashfs)"
  mkdir -p ${flight_ENV_ROOT}/share/squashfs/${SQUASHFS_VER}/bin
  mv mksquashfs unsquashfs ${flight_ENV_ROOT}/share/squashfs/${SQUASHFS_VER}/bin
  cd ../..
fi

if [ ! -f go${GO_VER}.linux-amd64.tar.gz ]; then
  env_stage "Fetching prerequisite (go)"
  wget https://go.dev/dl/go1.20.7.linux-amd64.tar.gz
  env_stage "Extracting prerequisite (go)"
  tar xzf go${GO_VER}.linux-amd64.tar.gz
fi

if [ ! -f apptainer-${APPTAINER_VER}.tar.gz ]; then
  env_stage "Fetching prerequisite (apptainer)"
  wget -O apptainer-${APPTAINER_VER}.tar.gz https://github.com/apptainer/apptainer/releases/download/v${APPTAINER_VER}/apptainer-${APPTAINER_VER}.tar.gz
  export GOPATH=${flight_ENV_BUILD_CACHE}/go
  export PATH=${GOPATH}/bin:$PATH
  env_stage "Extracting prerequisite (apptainer)"
  tar xzf ${flight_ENV_BUILD_CACHE}/apptainer-${APPTAINER_VER}.tar.gz
  mv apptainer-${APPTAINER_VER} apptainer
  cd apptainer
  env_stage "Building prerequisite (apptainer)"
  if [ "$UID" == "0" ]; then
    ./mconfig --with-suid -b ./builddir --prefix=${flight_ENV_ROOT}/share/apptainer/${APPTAINER_VER}
  else
    ./mconfig --without-suid -b ./builddir --prefix=${flight_ENV_ROOT}/share/apptainer/${APPTAINER_VER}
  fi
  cd builddir
  make
  env_stage "Installing prerequisite (apptainer)"
  make install
  sed -e "s,# binary path =.*,binary path = ${flight_ENV_ROOT}/share/squashfs/${SQUASHFS_VER}/bin:\$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin,g" \
      -i "${flight_ENV_ROOT}"/share/apptainer/${APPTAINER_VER}/etc/apptainer/apptainer.conf
fi

env_stage "Creating environment (apptainer@${name})"
mkdir -p "${flight_ENV_ROOT}/apptainer+${name}"
