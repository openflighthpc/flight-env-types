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

name=$1

# Use flight-python to install the temporary version of EasyBuild.
PATH=/opt/flight/opt/python/bin:$PATH
PYTHON=python

# Pick installation prefix, and install EasyBuild into it
export EB_TMPDIR=/tmp/$USER/eb_tmp
$PYTHON -m pip install --ignore-installed --prefix $EB_TMPDIR easybuild

# Update environment to use the temporary EasyBuild installation.
export PATH=$EB_TMPDIR/bin:$PATH
export PYTHONPATH=$(/bin/ls -rtd -1 $EB_TMPDIR/lib*/python*/site-packages | tail -1):$PYTHONPATH
export EB_PYTHON=$PYTHON

eb --install-latest-eb-release --prefix ${flight_ENV_ROOT}/easybuild+${name}
