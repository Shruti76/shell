#!/bin/false

export PYPI_SERVER="${PYPI_SERVER:-https://artifactory-espoo1.int.net.nokia.com/artifactory/api/pypi/cb-pypi-virtual/simple}"

mkdir -p "$HOME/.pip/"

sed 's#%%PYPI%%#'"${PYPI_SERVER}"'#g' "${script_dir:?}/data/pip.conf.tmpl" > "${HOME}/.pip/pip.conf"
sed 's#%%PYPI%%#'"${PYPI_SERVER}"'#g' "${script_dir:?}/data/pydistutils.cfg.tmpl" > "${HOME}/.pydistutils.cfg"

python3-virtualenv() {
  edebug "Creating python3 virtualenv"
  local virtualenv_path
  if [[ -z ${2+x} ]]; then
    virtualenv_path="$(select_tool "pyvenv" "pyvenv-3" "/build/ltesdkroot/Tools/Tools/python/python-3.3.2/bin/pyvenv")"
  else
    virtualenv_path="${2}"
  fi
  create_venv "${virtualenv_path}" "${1:-venv}"
  get_pip "${1:-venv}"
}

python2-virtualenv() {
  edebug "Creating python2 virtualenv"
  local virtualenv_path="$(select_tool "/build/ltesdkroot/Tools/Tools/python/python-2.7.6/bin/virtualenv" "virtualenv")"
  create_venv "${virtualenv_path}" "${1:-venv}"
  get_pip "${1:-venv}"
}

create_venv() {
  dir="${2:?}"
  if [ -d "${WORKSPACE}/${dir}" ]; then
    rm -rf "${WORKSPACE}/${dir}"
  fi
  "${1}" "${WORKSPACE}/${dir}"
  # shellcheck source=/dev/null
  source "${WORKSPACE}/${dir}/bin/activate"
}

get_pip() {
    if [[ -f "${WORKSPACE}/${1}/bin/pip" ]]; then
        update_pip
    else
        download_pip
    fi
}

update_pip() {
    edebug "Updating pip"
    pip install pip --upgrade > /dev/null
}

download_pip() {
  edebug "Downloading pip"
  TMPDIR=$(mktemp -d)
  wget -q "${ARTIFACTORY_URL:-http://artifactory-espoo1.int.net.nokia.com}/artifactory/scm-binaries-local/bins/get-pip/get-pip.py" -O "${TMPDIR}/get-pip.py"
  python "${TMPDIR}/get-pip.py" --upgrade --no-cache-dir #FIXME turn off cache - ticket CAL2190085
  rm "${TMPDIR}/get-pip.py"
}

select_tool() {
    for virttool in $@; do
      if which "$virttool" >/dev/null 2>&1; then
          echo "$virttool"
          return
      fi
    done
    die "Can't create virtualenv"
}

pip() {
  run --no-dry retry 3 "$(which pip)" "$@"
}
export -f pip

pip3() {
  run --no-dry retry 3 "$(which pip3)" "$@"
}
export -f pip3
