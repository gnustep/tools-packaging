# -*- mode: makefile; coding: utf-8 -*-

# Variables used by this file:
# DEB_GS_FRAMEWORKS
#   A list of the frameworks to install.
# DEB_GS_APPLICATIONS
#   A list of the frameworks to install.
# DEB_GS_LIBRARIES
#   A list of the frameworks to install.
# DEB_GS_LCNAME_<Component>
#   The name of a package, lower case (defaults to "<Component> | y/A-Z/a-z/").
# DEB_GS_APPLICATION_PKG_NAME_<Application>
#   The name of the framework dependency package (defaults to
#   <lcname>.app).
# DEB_GS_INTERFACE_VERSION_<Component>
#   The interface version (soname) of a framework or library (defaults to "0").
# DEB_GS_CURRENT_VERSION_NAME_<Framework>
#   The current version name of the framework (defaults to <soname>).
# DEB_GS_LIBPKG_NAME_<Component>
#   The name of the library package (defaults to lib<lcname><soname>).
# DEB_GS_DEVPKG_NAME_<Component>
#   The name of the development package (defaults to <libpackage>-dev).
# DEB_GS_FRAMEWORK_PKG_NAME_<Framework>
#   The name of the framework dependency package (defaults to
#   <lcname>.framework).
# DEB_GS_AUTO_LINTIAN_OVERRIDES
# DEB_GS_AUTO_LINTIAN_OVERRIDES_<Component>
#   Use a default set of lintian overrides (deprecated)
# DEB_GS_AUTO_DH_INSTALL
# DEB_GS_AUTO_DH_INSTALL_<Component>
#   Use a default set of install files

ifndef _cdbs_bootstrap
_cdbs_scripts_path ?= /usr/lib/cdbs
_cdbs_rules_path ?= /usr/share/cdbs/1/rules
_cdbs_class_path ?= /usr/share/cdbs/1/class
endif

include $(_cdbs_rules_path)/debhelper.mk

__gs_set_default_value = $(if $($(1)),,$(eval $(1) = $(2)))


# GNUstep settings
_gs_debian_dir = /usr/share/GNUstep/debian
include $(_gs_debian_dir)/config.mk
GS_FRAMEWORKS_DIR = $(GNUSTEP_SYSTEM_LIBRARY)/Frameworks


DEB_DH_INSTALL_SOURCEDIR = $(DEB_DESTDIR)

$(patsubst %,binary-install/%,$(DEB_PACKAGES)) :: binary-install/%:
	gsdh_gnustep -p$(cdbs_curpkg)
	dh_link -p$(cdbs_curpkg)

# convenience variables
__gs_curcomponent = $(filter-out %/,$(subst /,/ ,$@))
__gs_cur_framework_pkg=$(DEB_GS_FRAMEWORK_PKG_NAME_$(__gs_curcomponent))
__gs_cur_apppkg=$(DEB_GS_APPLICATION_PKG_NAME_$(__gs_curcomponent))
__gs_cur_libpkg=$(DEB_GS_LIBPKG_NAME_$(__gs_curcomponent))
__gs_cur_devpkg=$(DEB_GS_DEVPKG_NAME_$(__gs_curcomponent))
__gs_cur_appdir=debian/$(__gs_cur_apppkg)
__gs_cur_libdir=debian/$(__gs_cur_libpkg)
__gs_cur_devdir=debian/$(__gs_cur_devpkg)
__gs_cur_ver=$(DEB_GS_CURRENT_VERSION_NAME_$(__gs_curcomponent))


#####
# Applications:
#####

define __gs_application_set_default_values
  $(call __gs_set_default_value,DEB_GS_LCNAME_$(1),$(shell echo $(1) | tr [A-Z] [a-z]))
  $(call __gs_set_default_value,DEB_GS_APPLICATION_PKG_NAME_$(1),$(DEB_GS_LCNAME_$(1)).app)
endef

$(foreach application,$(DEB_GS_APPLICATIONS),$(eval $(call __gs_application_set_default_values,$(application))))


clean:: $(patsubst %,gs-clean/%,$(DEB_GS_APPLICATIONS))

define __gs_application_rm_dh_install
rm -f debian/$(__gs_cur_apppkg).install
endef

$(patsubst %,gs-clean/%,$(DEB_GS_APPLICATIONS)) :: gs-clean/%:
# remove automatically generated .install files
	$(if $(DEB_GS_AUTO_DH_INSTALL)$(DEB_GS_AUTO_DH_INSTALL_$(__gs_curcomponent)),$(__gs_application_rm_dh_install))


common-install-prehook-arch:: $(patsubst %,gs-pre-install/%,$(DEB_GS_APPLICATIONS))


define __gs_application_update_dh_install
sed -e "s:@GNUSTEP_SYSTEM_APPS@:$(GNUSTEP_SYSTEM_APPS):g" \
	-e "s:@GNUSTEP_SYSTEM_TOOLS@:$(GNUSTEP_SYSTEM_TOOLS):g" \
	-e "s/@APPLICATION@/$(__gs_curcomponent)/g" \
	< $(_gs_debian_dir)/application.install.in \
	> debian/$(__gs_cur_apppkg).install
endef

$(patsubst %,gs-pre-install/%,$(DEB_GS_APPLICATIONS)) :: gs-pre-install/%:
# generate the install files
	$(if $(DEB_GS_AUTO_DH_INSTALL)$(DEB_GS_AUTO_DH_INSTALL_$(__gs_curcomponent)),$(__gs_application_update_dh_install))


#####
# Frameworks:
#####

define __gs_framework_set_default_values
  $(call __gs_set_default_value,DEB_GS_LCNAME_$(1),$(shell echo $(1) | tr [A-Z] [a-z]))
  $(call __gs_set_default_value,DEB_GS_INTERFACE_VERSION_$(1),0)
  $(call __gs_set_default_value,DEB_GS_CURRENT_VERSION_NAME_$(1),$(DEB_GS_INTERFACE_VERSION_$(1)))
  $(call __gs_set_default_value,DEB_GS_LIBPKG_NAME_$(1),lib$(DEB_GS_LCNAME_$(1))$(DEB_GS_INTERFACE_VERSION_$(1)))
  $(call __gs_set_default_value,DEB_GS_DEVPKG_NAME_$(1),$(DEB_GS_LIBPKG_NAME_$(1))-dev)
  $(call __gs_set_default_value,DEB_GS_FRAMEWORK_PKG_NAME_$(1),$(DEB_GS_LCNAME_$(1)).framework)
endef

$(foreach framework,$(DEB_GS_FRAMEWORKS),$(eval $(call __gs_framework_set_default_values,$(framework))))


__gs_frameworks_dev_packages = $(foreach framework,$(DEB_GS_FRAMEWORKS),$(DEB_GS_DEVPKG_NAME_$(framework)))


clean:: $(patsubst %,gs-clean/%,$(DEB_GS_FRAMEWORKS))

define __gs_framework_rm_dh_install
rm -f debian/$(__gs_cur_libpkg).install
rm -f debian/$(__gs_cur_devpkg).install
endef

$(patsubst %,gs-clean/%,$(DEB_GS_FRAMEWORKS)) :: gs-clean/%:
# remove automatically generated .install files
	$(if $(DEB_GS_AUTO_DH_INSTALL)$(DEB_GS_AUTO_DH_INSTALL_$(__gs_curcomponent)),$(__gs_framework_rm_dh_install))


common-install-prehook-arch:: $(patsubst %,gs-pre-install/%,$(DEB_GS_FRAMEWORKS))

define __gs_framework_update_dh_install
sed -e "s:@GNUSTEP_SYSTEM_LIBRARIES@:$(GNUSTEP_SYSTEM_LIBRARIES):g" \
	-e "s:@GNUSTEP_SYSTEM_LIBRARY@:$(GNUSTEP_SYSTEM_LIBRARY):g" \
	-e "s:@GNUSTEP_SYSTEM_HEADERS@:$(GNUSTEP_SYSTEM_HEADERS):g" \
	-e "s/@FRAMEWORK@/$(__gs_curcomponent)/g; s/@FRAMEWORKVER@/$(__gs_cur_ver)/g" \
	< $(_gs_debian_dir)/frameworklib.install.in \
	> debian/$(__gs_cur_libpkg).install
sed -e "s:@GNUSTEP_SYSTEM_LIBRARIES@:$(GNUSTEP_SYSTEM_LIBRARIES):g" \
	-e "s:@GNUSTEP_SYSTEM_LIBRARY@:$(GNUSTEP_SYSTEM_LIBRARY):g" \
	-e "s:@GNUSTEP_SYSTEM_HEADERS@:$(GNUSTEP_SYSTEM_HEADERS):g" \
	-e "s/@FRAMEWORK@/$(__gs_curcomponent)/g; s/@FRAMEWORKVER@/$(__gs_cur_ver)/g" \
	< $(_gs_debian_dir)/frameworkdev.install.in \
	> debian/$(__gs_cur_devpkg).install
endef

$(patsubst %,gs-pre-install/%,$(DEB_GS_FRAMEWORKS)) :: gs-pre-install/%:
# Issue a warning if DEB_GS_AUTO_LINTIAN_OVERRIDES is defined.
	$(if $(DEB_GS_AUTO_LINTIAN_OVERRIDES)$(DEB_GS_AUTO_LINTIAN_OVERRIDES_$(__gs_curcomponent)),$(warning DEB_GS_AUTO_LINTIAN_OVERRIDES has been deprecated.))
# generate the install files
	$(if $(DEB_GS_AUTO_DH_INSTALL)$(DEB_GS_AUTO_DH_INSTALL_$(__gs_curcomponent)),$(__gs_framework_update_dh_install))


#####
# Libraries
#####

define __gs_library_set_default_values
  $(call __gs_set_default_value,DEB_GS_LCNAME_$(1),$(shell echo $(1) | tr [A-Z] [a-z]))
  $(call __gs_set_default_value,DEB_GS_CURRENT_VERSION_NAME_$(1),A)
  $(call __gs_set_default_value,DEB_GS_INTERFACE_VERSION_$(1),0)
  $(call __gs_set_default_value,DEB_GS_LIBPKG_NAME_$(1),lib$(DEB_GS_LCNAME_$(1))$(DEB_GS_INTERFACE_VERSION_$(1)))
  $(call __gs_set_default_value,DEB_GS_DEVPKG_NAME_$(1),$(DEB_GS_LIBPKG_NAME_$(1))-dev)
endef

$(foreach library,$(DEB_GS_LIBRARIES),$(eval $(call __gs_library_set_default_values,$(library))))


clean:: $(patsubst %,gs-clean/%,$(DEB_GS_LIBRARIES))

define __gs_library_rm_dh_install
rm -f debian/$(__gs_cur_libpkg).install
rm -f debian/$(__gs_cur_devpkg).install
endef

$(patsubst %,gs-clean/%,$(DEB_GS_LIBRARIES)) :: gs-clean/%:
# remove automatically generated .install files
	$(if $(DEB_GS_AUTO_DH_INSTALL)$(DEB_GS_AUTO_DH_INSTALL_$(__gs_curcomponent)),$(__gs_library_rm_dh_install))


common-install-prehook-arch:: $(patsubst %,gs-pre-install/%,$(DEB_GS_LIBRARIES))

define __gs_library_update_dh_install
sed -e "s:@GNUSTEP_SYSTEM_LIBRARIES@:$(GNUSTEP_SYSTEM_LIBRARIES):g" \
	-e "s/@LIBRARY@/$(__gs_curcomponent)/g" \
	< $(_gs_debian_dir)/lib.install.in \
	> debian/$(__gs_cur_libpkg).install
sed -e "s:@GNUSTEP_SYSTEM_LIBRARIES@:$(GNUSTEP_SYSTEM_LIBRARIES):g" \
	-e "s:@GNUSTEP_SYSTEM_HEADERS@:$(GNUSTEP_SYSTEM_HEADERS):g" \
	-e "s/@LIBRARY@/$(__gs_curcomponent)/g" \
	< $(_gs_debian_dir)/libdev.install.in \
	> debian/$(__gs_cur_devpkg).install
endef

$(patsubst %,gs-pre-install/%,$(DEB_GS_LIBRARIES)) :: gs-pre-install/%:
# generate the install files
	$(if $(DEB_GS_AUTO_DH_INSTALL)$(DEB_GS_AUTO_DH_INSTALL_$(__gs_curcomponent)),$(__gs_library_update_dh_install))
