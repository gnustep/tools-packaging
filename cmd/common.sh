#!/bin/bash
# Description: Common variables and functions for all scripts


SOURCE_DIR="${SCRIPT_DIR}/../source"
SOURCE_DESC_DIR="$SOURCE_DIR/desc"
SOURCE_DEB_DIR="$SOURCE_DIR/debian"

# Build only this package
ONLY_PKG=""
VERBOSE=1

# Debian building configuration
PBUILDER_DIR="${SCRIPT_DIR}/../pbuilder"
PBUILDER_CONFIG="${PBUILDER_DIR}/pbuilderrc"
PBUILDER_BASE_TGZ="${PBUILDER_DIR}/base-${DEBIAN_RELEASE}-${ARCHITECTURE}.tgz"
PBUILDER_RESULT="/var/cache/pbuilder/result"
PBUILDER_DEFAULT_ARGS="--basetgz ${PBUILDER_BASE_TGZ} --distribution ${DEBIAN_RELEASE} --architecture ${ARCHITECTURE} --configfile ${PBUILDER_CONFIG} --hookdir ${PBUILDER_DIR}/hooks"
PBUILDER_SKIP_UPDATE=0

# Debian release version. By default the unstable version (sid) is used.
DEBIAN_RELEASE="sid"
ARCHITECTURE=arm64