#!/bin/bash -i
# =================================================================================================
#
# Libnabo documentation dependencies installer
#
# Usage:
#   $ bash nabo_install_doc_dependencies_ubuntu.bash [--test-run]
#
# =================================================================================================
set -e # Note: we want the installer to always fail-fast (it wont affect the build system policy)

declare -a  APT_FLAGS

## skip GUI dialog by setting everything to default
export DEBIAN_FRONTEND=noninteractive

# ....Project root logic...........................................................................
TMP_CWD=$(pwd)

NABO_PATH=$(git rev-parse --show-toplevel)
cd "${NABO_PATH}/build_system" || exit 1


# ....Load environment variables from file.........................................................
set -o allexport
source .env
set +o allexport

# ....Helper function..............................................................................
# import shell functions from utilities library
N2ST_PATH=${N2ST_PATH:-"${NABO_PATH}/build_system/utilities/norlab-shell-script-tools"}
source "${N2ST_PATH}/import_norlab_shell_script_tools_lib.bash"

# Set environment variable IMAGE_ARCH_AND_OS
cd "${N2ST_PATH}"/src/utility_scripts/ && source "which_architecture_and_os.bash"

# ====Begin========================================================================================
SHOW_SPLASH_IDDU="${SHOW_SPLASH_IDDU:-true}"

if [[ "${SHOW_SPLASH_IDDU}" == 'true' ]]; then
  norlab_splash "${NBS_SPLASH_NAME:?err}" "https://github.com/${NBS_REPOSITORY_DOMAIN:?err}/${NBS_REPOSITORY_NAME:?err}"
fi

print_formated_script_header "nabo_install_doc_dependencies_ubuntu.bash (${IMAGE_ARCH_AND_OS:?err})" "${MSG_LINE_CHAR_INSTALLER}"

# ....Script command line flags....................................................................
while [ $# -gt 0 ]; do

  case $1 in
  --test-run)
    APT_FLAGS=( --dry-run )
    shift
    ;;
  --?* | -?*)
    echo "$0: $1: unrecognized option" >&2 # Note: '>&2' = print to stderr
    shift
    ;;
  *) # Default case
    break
    ;;
  esac

done


# .................................................................................................
teamcity_service_msg_blockOpened "Install libnabo documentation related dependencies"

## Package required when LIBNABO_BUILD_DOXYGEN flag is set to true
## Note: 'texlive-full' is ~6GB. 'doxygen-latex' is a slim version tailor made for doxygen code documentation task
sudo apt-get update \
 && sudo apt-get install --assume-yes "${APT_FLAGS[@]}" \
      doxygen \
      doxygen-latex \
 && sudo rm -rf /var/lib/apt/lists/*

teamcity_service_msg_blockClosed

echo " " && print_msg_done "Libnabo documentation related dependencies installed"
print_formated_script_footer "nabo_install_doc_dependencies_ubuntu.bash (${IMAGE_ARCH_AND_OS})" "${MSG_LINE_CHAR_INSTALLER}"
# ====Teardown=====================================================================================
cd "${TMP_CWD}"

