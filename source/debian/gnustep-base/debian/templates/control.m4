# -*-debian-control-*-
# NOTE: debian/control is generated from debian/templates/control.m4
Source: gnustep-base
Maintainer: Hugo Melder <contact@hugomelder.com>
Section: libs
Priority: optional
Build-Depends: debhelper-compat (= 13),
               gnustep-make (>= V_MAKE),
               gnutls-bin <!nocheck>,
               libffi-dev,
               libxml2-dev,
               libxslt1-dev,
               libgnutls28-dev,
               zlib1g-dev,
               m4,
               libavahi-client-dev,
               libicu-dev,
               tzdata,
               libcurl4-openssl-dev,
               libdispatch-dev,
               libobjc2-dev,
               pkg-config,
Build-Depends-Indep: texinfo <!nodoc>,
                     texlive-latex-base <!nodoc>,
                     texlive-fonts-recommended <!nodoc>,
                     xml-core
Rules-Requires-Root: no
Standards-Version: 4.6.2
Homepage: http://gnustep.org

Package: gnustep-base-common
Architecture: all
Depends: gnustep-common (>= V_MAKE),
         ca-certificates,
         tzdata,
         ${misc:Depends}
Description: GNUstep Base library - common files
 The GNUstep Base Library is a powerful fast library of
 general-purpose, non-graphical Objective C classes, inspired by the
 OpenStep API but implementing Apple and GNU additions to the API as
 well.
 .
 This package contains the common files needed by the GNUstep Base library.

Package: gnustep-base-runtime
Architecture: any
Depends: gnustep-base-common (= ${source:Version}),
         ${shlibs:Depends},
         ${misc:Depends},
Description: GNUstep Base library - daemons and tools
 The GNUstep Base Library is a powerful fast library of
 general-purpose, non-graphical Objective C classes, inspired by the
 OpenStep API but implementing Apple and GNU additions to the API as
 well.
 .
 This package contains the runtime support files needed by GNUstep
 applications.

Package: libgnustep-base`'SOV_BASE
Section: libs
Architecture: any
Depends: gnustep-base-common (= ${source:Version}),
         gnutls-bin,
         ${shlibs:Depends},
         ${misc:Depends}
Recommends: gnustep-base-runtime (= ${binary:Version})
Description: GNUstep Base library
 The GNUstep Base Library is a powerful fast library of
 general-purpose, non-graphical Objective C classes, inspired by the
 OpenStep API but implementing Apple and GNU additions to the API as
 well.  It includes for example classes for unicode strings, arrays,
 dictionaries, sets, byte streams, typed coders, invocations,
 notifications, notification dispatchers, scanners, tasks, files,
 networking, threading, remote object messaging support (distributed
 objects), event loops, loadable bundles, attributed unicode strings,
 xml, mime, user defaults.

Package: libgnustep-base-dev
Section: libdevel
Architecture: any
Depends: libgnustep-base`'SOV_BASE (= ${binary:Version}),
         gnustep-base-runtime (= ${binary:Version}),
         gnustep-make (>= V_MAKE),
         ${misc:Depends}
Suggests: gnustep-base-doc
Description: GNUstep Base header files and development libraries
 This package contains the header files and static libraries required
 to build applications against the GNUstep Base library.
 .
 Install this package if you wish to develop your own programs using
 the GNUstep Base Library.

Package: gnustep-base-doc
Section: doc
Architecture: all
Build-Profiles: <!nodoc>
Multi-Arch: foreign
Depends: ${misc:Depends}
Recommends: libgnustep-base-dev
Description: Documentation for the GNUstep Base Library
 This package contains the GNUstep Base Library API reference, as well
 as the GNUstep Base programming manual and GNUstep Coding Standards
 in Info, HTML and PDF format.
