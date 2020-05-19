#!/bin/bash
# =============================================================================
# Copyright (C) 2020-present Alces Flight Ltd.
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

flight_ENV_ROOT=${flight_ENV_ROOT:-$HOME/.local/share/flight/env}
flight_ENV_CACHE=${flight_ENV_CACHE:-$HOME/.cache/flight/env}
flight_ENV_BUILD_CACHE=${flight_ENV_BUILD_CACHE:-$HOME/.cache/flight/env/build}
name=$1

if [ -z "$name" ]; then
  echo "error: environment name not supplied"
  exit 1
fi

# create directory structure
mkdir -p ${flight_ENV_CACHE} ${flight_ENV_BUILD_CACHE} ${flight_ENV_ROOT}
cd ${flight_ENV_BUILD_CACHE}

# XXX - satisfy ExtUtils::MakeMaker dependency somehow

env_stage "Creating Homebrew hierarchy (brew@${name})"
BREW_REPO="https://github.com/Homebrew/brew"
# no analytics during installation
export HOMEBREW_NO_ANALYTICS_THIS_RUN=1
export HOMEBREW_NO_ANALYTICS_MESSAGE_OUTPUT=1
export HOMEBREW_CACHE="${flight_ENV_CACHE}/homebrew"
export HOMEBREW_LOGS="${flight_ENV_CACHE}/homebrew/Logs"
HOMEBREW_PREFIX="${flight_ENV_ROOT}/brew+${name}"
HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"

# Keep relatively in sync with
# https://github.com/Homebrew/brew/blob/master/Library/Homebrew/keg.rb
directories=(bin etc include lib sbin share var opt
             share/zsh share/zsh/site-functions
             var/homebrew var/homebrew/linked
             Cellar Caskroom Homebrew Frameworks)
mkdirs=()
for dir in "${directories[@]}"; do
  if ! [[ -d "${HOMEBREW_PREFIX}/${dir}" ]]; then
    mkdirs+=("${HOMEBREW_PREFIX}/${dir}")
  fi
done

mkdir -p "${HOMEBREW_PREFIX}"

if [[ "${#mkdirs[@]}" -gt 0 ]]; then
  mkdir -p "${mkdirs[@]}"
  chmod g+rwx "${mkdirs[@]}"
fi

mkdir -p "${HOMEBREW_CACHE}"

env_stage "Bootstrapping Homebrew environment (brew@${name})"
(
  cd "${HOMEBREW_REPOSITORY}" >/dev/null || return

  # we do it in four steps to avoid merge errors when reinstalling
  git init -q

  # "git remote add" will fail if the remote is defined in the global config
  git config remote.origin.url "${BREW_REPO}"
  git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

  # ensure we don't munge line endings on checkout
  git config core.autocrlf false

  git fetch origin --force
  git fetch origin --tags --force

  git reset --hard origin/master

  ln -sf "${HOMEBREW_REPOSITORY}/bin/brew" "${HOMEBREW_PREFIX}/bin/brew"

  "${HOMEBREW_PREFIX}"/bin/brew update --force

  cd "${HOMEBREW_REPOSITORY}" >/dev/null || return
  git config --replace-all homebrew.analyticsmessage true
  git config --replace-all homebrew.caskanalyticsmessage true
)
