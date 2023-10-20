# -*- makefile-gmake -*-
# Configuration variables describing the GNUstep paths

GS_USE_FHS 	:= yes

GS_MAKE_DIR	:= /usr/share/GNUstep/Makefiles

include /usr/share/GNUstep/Makefiles/filesystem.make
export GNUSTEP_MAKEFILES := $(GS_MAKE_DIR)
export GNUSTEP_INSTALLATION_DOMAIN := SYSTEM

# Optimization is handled automatically by debhelper but
# gnustep-make's debug=yes adds -DDEBUG -fno-omit-frame-pointer.
ifndef optim
ifneq (,$(findstring noopt,$(DEB_BUILD_OPTIONS)))
optim := debug=yes
endif
endif

# Support for "terse" in DEB_BUILD_OPTIONS (Policy §4.9.1).
ifndef verbose
ifeq (,$(findstring terse,$(DEB_BUILD_OPTIONS)))
verbose := messages=yes
endif
endif

# Support for "nodoc" in DEB_BUILD_OPTIONS (Policy §4.9.1).
# Note that not all GNUstep packages comply with the (unwritten) rule
# to build documentation only when the "doc" variable is defined to
# "yes"; so you might need to make some extra adjustments.
ifndef docs
ifeq (,$(findstring nodoc,$(DEB_BUILD_OPTIONS)))
docs := doc=yes
endif
endif
