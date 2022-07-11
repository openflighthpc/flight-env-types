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

tcl_v=8.6.9
tcl_mv=8.6
v=4.3.0

env_stage "Verifying prerequisites"
if [ ! -d "${flight_ENV_ROOT}"/share/modules/${v} ]; then
  if [ ! -d ${flight_ENV_ROOT}/share/tcl/${tcl_v} ]; then
    if [ ! -f tcl${tcl_v}-src.tar.gz ]; then
      env_stage "Fetching prerequisite (tcl)"
      wget https://prdownloads.sourceforge.net/tcl/tcl${tcl_v}-src.tar.gz
    fi
    env_stage "Extracting prerequisite (tcl)"
    tar xzf tcl${tcl_v}-src.tar.gz
    env_stage "Building prerequisite (tcl)"
    cd tcl${tcl_v}/unix
    ./configure --prefix=${flight_ENV_ROOT}/share/tcl/${tcl_v}
    make
    env_stage "Installing prerequisite (tcl)"
    make install
    ln -s ${flight_ENV_ROOT}/share/tcl/${tcl_v}/bin/tclsh${tcl_mv} ${flight_ENV_ROOT}/share/tcl/${tcl_v}/bin/tclsh
    cd ../..
  fi
  tcl_params="--with-tcl=${flight_ENV_ROOT}/share/tcl/${tcl_v}/lib --with-tclsh=${flight_ENV_ROOT}/share/tcl/${tcl_v}/bin/tclsh --with-tcl-ver=${tcl_mv} --without-tclx"
  if [ ! -f modules-${v}.tar.gz ]; then
    env_stage "Fetching prerequisite (modules)"
    wget https://sourceforge.net/projects/modules/files/Modules/modules-${v}/modules-${v}.tar.gz
  fi
  env_stage "Extracting prerequisite (modules)"
  tar xzf modules-${v}.tar.gz
  env_stage "Building prerequisite (modules)"
  cd modules-${v}
  ./configure \
          --disable-versioning \
          --prefix=${flight_ENV_ROOT}/share/modules/${v} $tcl_params
  make
  env_stage "Installing prerequisite (modules)"
  make install
fi

env_stage "Creating environment (modules@${name})"

mkdir -p ${flight_ENV_ROOT}/modules+${name}/modulefiles
cp ${flight_ENV_ROOT}/share/modules/${v}/modulefiles/null ${flight_ENV_ROOT}/modules+${name}/modulefiles
cat <<EOF > ${flight_ENV_ROOT}/modules+${name}/modules.bash.rc
module use ${flight_ENV_ROOT}/modules+${name}/modulefiles
EOF
cat <<EOF > ${flight_ENV_ROOT}/modules+${name}/modules.tcsh.rc
module use ${flight_ENV_ROOT}/modules+${name}/modulefiles
EOF
