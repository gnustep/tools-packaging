#!/usr/bin/env bash

# pbuilder is not smart enough to resolve local dependencies automatically
# Resolving dependencies automatically is not needed for this scale.
BUILD_PHASES_ARRAY=(
    "libobjc2"
    "libdispatch"
    "gnustep2.0-make"
    "gnustep2.0-base"
)