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

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

flight_ENV_ROOT=${flight_ENV_ROOT:-$HOME/.local/share/flight/env}
flight_ENV_CACHE=${flight_ENV_CACHE:-$HOME/.cache/flight/env}
flight_ENV_BUILD_CACHE=${flight_ENV_BUILD_CACHE:-$HOME/.cache/flight/env/build}
name=$1

if [ -z "$name" ]; then
  echo "error: environment name not supplied"
  exit 1
fi

# Create directory structure
mkdir -p ${flight_ENV_CACHE} ${flight_ENV_BUILD_CACHE} ${flight_ENV_ROOT}
cd ${flight_ENV_BUILD_CACHE}

lua_v=5.1.4.9
tcl_v=8.6.9
tcl_mv=8.6
lmod_v=8.1

# Stop any existing activated EasyBuild environment from getting in
# the way.
MODULEPATH=""

if [ -f /etc/redhat-release ] && grep -q 'release 8' /etc/redhat-release; then
  distro=rhel8
fi

if [ -f /etc/redhat-release ] && grep -q 'release 9' /etc/redhat-release; then
  distro=rhel9
fi

env_stage "Verifying prerequisites"

if [[ "$distro" != "rhel8" && "$distro" != "rhel9" ]]; then
  # Build LUA
  if [ ! -f lua-${lua_v}.tar.bz2 ]; then
    env_stage "Fetching prerequisite (lua)"
    wget https://sourceforge.net/projects/lmod/files/lua-${lua_v}.tar.bz2
  fi
  if [ ! -d lua-${lua_v} ]; then
    env_stage "Extracting prerequisite (lua)"
    tar xjf lua-${lua_v}.tar.bz2
  fi
  if [ ! -d ${flight_ENV_ROOT}/share/lua/${lua_v} ]; then
    cd lua-${lua_v}
    env_stage "Building prerequisite (lua)"
    ./configure --with-static=yes --prefix=${flight_ENV_ROOT}/share/lua/${lua_v}
    make
    env_stage "Installing prerequisite (lua)"
    make install
    cd ..
  fi
  PATH=${flight_ENV_ROOT}/share/lua/${lua_v}/bin:$PATH
fi

# Build Tcl
if [ ! -d ${flight_ENV_ROOT}/share/tcl/${tcl_v} ]; then
  if [ ! -f tcl${tcl_v}-src.tar.gz ]; then
    env_stage "Fetching prerequisite (tcl)"
    wget https://prdownloads.sourceforge.net/tcl/tcl${tcl_v}-src.tar.gz
  fi
  env_stage "Extracting prerequisite (tcl)"
  tar xzf tcl${tcl_v}-src.tar.gz
  cd tcl${tcl_v}/unix
  env_stage "Building prerequisite (tcl)"
  ./configure --prefix=${flight_ENV_ROOT}/share/tcl/${tcl_v}
  make
  env_stage "Installing prerequisite (tcl)"
  make install
  ln -s ${flight_ENV_ROOT}/share/tcl/${tcl_v}/bin/tclsh${tcl_mv} ${flight_ENV_ROOT}/share/tcl/${tcl_v}/bin/tclsh
  cd ../..
fi
PATH=${flight_ENV_ROOT}/share/tcl/${tcl_v}/bin:$PATH

# Build lmod.
if [ ! -f Lmod-${lmod_v}.tar.bz2 ]; then
  env_stage "Fetching prerequisite (lmod)"
  wget https://sourceforge.net/projects/lmod/files/Lmod-${lmod_v}.tar.bz2
fi
if [ ! -d Lmod-${lmod_v} ]; then
  env_stage "Extracting prerequisite (lmod)"
  tar xjf Lmod-${lmod_v}.tar.bz2
fi
if [ ! -f ${flight_ENV_ROOT}/share/lmod/${lmod_v}/lmod/${lmod_v}/init/profile ]; then
  cd Lmod-${lmod_v}
  env_stage "Configuring prerequisite (lmod)"
  ./configure --prefix=${flight_ENV_ROOT}/share/lmod/${lmod_v} --with-fastTCLInterp=no
  env_stage "Installing prerequisite (lmod)"
  make install
  cd ..
fi

# Activate `module` command
. ${flight_ENV_ROOT}/share/lmod/${lmod_v}/lmod/${lmod_v}/init/profile

env_stage "Bootstrapping EasyBuild environment (easybuild@${name})"

/bin/bash "${SCRIPT_DIR}/stage-2-install.sh" "${name}"

# Remove the temporary EasyBuild installation.
rm -rf "$EB_TMPDIR"
