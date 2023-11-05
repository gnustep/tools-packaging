#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Local Options
ONLY_SOURCE_PKGS=0
ONLY_BINARY_PKGS=0

# Import common variables and functions
source ${SCRIPT_DIR}/common.sh
if test $VERBOSE -eq 1; then
    echo "DEBUG: Sourced ${SCRIPT_DIR}/common.sh"
fi

# Import Source Package Builder
source ${SCRIPT_DIR}/deb-build-packages.sh
if test $VERBOSE -eq 1; then
    echo "DEBUG: Sourced ${SCRIPT_DIR}/deb-build-packages.sh"
fi

# Check if the script is run as root
function checkRootNoFail {
    if [[ $EUID -ne 0 ]]; then
        echo "ERROR: This script must be run as root!"
        exit 1
    fi
}

# Check if all required binaries are installed.
# I do not understand why nobody does this when writing a shell script -_-
function checkRTDependenciesNoFail {
    # The following dependencies are only needed when building in a sandbox
    if test $NO_SANDBOX -eq 0; then
        # Check if pbuilder is installed
        if ! command -v pbuilder &> /dev/null; then
            echo "ERROR: pbuilder is not installed!"
            echo "ERROR: Install it with 'sudo apt install pbuilder'"
            exit 1
        fi
        # Check if we can create local debian repositories
        if ! command -v apt-ftparchive &> /dev/null; then
            echo "ERROR: apt-ftparchive is not installed! We need to create local debian repositories!"
            echo "ERROR: Install it with 'sudo apt install apt-utils'"
            exit 1
        fi
    fi

    # Check if objdump is installed
    if ! command -v objdump &> /dev/null; then
        echo "ERROR: objdump is not installed!"
        echo "ERROR: Install it with 'sudo apt install binutils'"
        exit 1
    fi
    
    # Check if we have dpkg-source installed
    if ! command -v dpkg-source &> /dev/null; then
        echo "ERROR: dpkg-dev is not installed!"
        echo "ERROR: Install it with 'sudo apt install dpkg-dev'"
        exit 1
    fi
    # Check if tar is installed
    if ! command -v tar &> /dev/null; then
        echo "ERROR: tar is not installed!"
        exit 1
    fi
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "ERROR: jq is not installed!"
        echo "ERROR: Install it with 'sudo apt install jq'"
        exit 1
    fi
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        echo "ERROR: git is not installed!"
        echo "ERROR: Install it with 'sudo apt install git'"
        exit 1
    fi
}

function usage {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help: Show this help message"
    echo "  -r, --release: Release version of the debian rootfs using for building the packages. Default: ${DEBIAN_RELEASE}"
    echo "  -a, --architecture: Architecture to build the packages for. Default: ${ARCHITECTURE}"
    echo "  -o, --only-pkg: Only build the specified package"
    echo "  -u, --skip-update: Skip updating the pbuilder base tarball"
    echo "  -e, --extract-only: Skip package build process"
    echo "  -w, --worker: This is only intended for a worker node. Do not use this option as it modifies the rootfs directly!"
}

function main {
    checkRootNoFail
    checkRTDependenciesNoFail
    echo "INFO: All runtime dependencies are installed and running with root privileges! Continuing..."

    # TODO: Write function for parsing json description files

    if test $ONLY_BINARY_PKGS -eq 0; then
        if ! buildPackages; then
            echo "ERROR: Failed to build source packages!"
            exit 1
        fi
    fi
}


# Parse options using a while loop and case statement
while (( "$#" )); do
case "$1" in
    -h | --help)
    usage
    exit 0
    ;;
    -u | --skip-update)
    PBUILDER_SKIP_UPDATE=1
    shift
    ;;
    -r|--release)
    if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        DEBIAN_RELEASE=$2
        shift 2
    else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
    fi
    ;;
    -a|--architecture)
    if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        ARCHITECTURE=$2
        shift 2
    else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
    fi
    ;;
    -o| --only-pkg)
    if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        ONLY_PKG=$2
        shift 2
    else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
    fi
    ;;
    -e | --extract-only)
    EXTRACT_ONLY=1
    SKIP_PBUILDER_INIT=1
    shift
    ;;
    -w | --worker)
    NO_SANDBOX=1
    SKIP_PBUILDER_INIT=1
    shift
    ;;
    -*|--*=) # unsupported flags
    echo "Error: Unsupported flag $1" >&2
    exit 1
    ;;
    *) # preserve positional arguments
    shift
    ;;
esac
done

# Run main function
main