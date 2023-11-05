#!/bin/bash
# Description: Common variables and functions for all scripts


SOURCE_DIR="${SCRIPT_DIR}/../source"
SOURCE_DESC_DIR="$SOURCE_DIR/description"
SOURCE_DEB_DIR="$SOURCE_DIR/debian"

SOURCE_TEMP_DEB_DIR=$SOURCE_DIR/../build/debian
SOURCE_TEMP_DIR=$SOURCE_DIR/../build

# Build only this package
ONLY_PKG=""
EXTRACT_ONLY=0
NO_SANDBOX=0
SKIP_PBUILDER_INIT=0
VERBOSE=1

# Debian release version. By default the unstable version (sid) is used.
DEBIAN_RELEASE="bookworm"
ARCHITECTURE=arm64
MIRROR="http://deb.debian.org/debian"
COMPONENTS="main"

# Debian building configuration
PBUILDER_DIR="${SCRIPT_DIR}/../pbuilder"
PBUILDER_CONFIG="${PBUILDER_DIR}/pbuilderrc"
PBUILDER_BASE_TGZ="${PBUILDER_DIR}/base-${DEBIAN_RELEASE}-${ARCHITECTURE}.tgz"
PBUILDER_RESULT="/var/cache/pbuilder/result"
PBUILDER_DEFAULT_ARGS="--basetgz ${PBUILDER_BASE_TGZ} --mirror ${MIRROR} --distribution ${DEBIAN_RELEASE} --components ${COMPONENTS} --architecture ${ARCHITECTURE} --configfile ${PBUILDER_CONFIG} --hookdir ${PBUILDER_DIR}/hooks"
PBUILDER_SKIP_UPDATE=0
