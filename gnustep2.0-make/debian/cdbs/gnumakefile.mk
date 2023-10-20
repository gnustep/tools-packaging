# -*- mode: makefile; coding: utf-8 -*-

ifndef _cdbs_bootstrap
_cdbs_scripts_path ?= /usr/lib/cdbs
_cdbs_rules_path ?= /usr/share/cdbs/1/rules
_cdbs_class_path ?= /usr/share/cdbs/1/class
endif

include $(_cdbs_class_path)/makefile.mk

include /usr/share/GNUstep/debian/config.mk
DEB_MAKE_ENVVARS = GNUSTEP_MAKEFILES=$(GS_MAKE_DIR)

DEB_MAKE_INSTALL_TARGET = install DESTDIR=$(DEB_DESTDIR) GNUSTEP_INSTALLATION_DOMAIN=SYSTEM
