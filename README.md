# Packaging modern GNUstep for Linux Distributions (WIP)

This repository hosts dpkg build configuration files for the Debian GNU/Linux distribution.
The goal is to provide a modern, and stable distribution of the GNUstep Objective-C 2.0 Runtime,
Apple's Grand Central Dispatch, GNUstep Makefiles, and GNUstep Base (a.k.a. Foundation).

Please note that the packages are experimental, and not ready for production.

## TODO
libobjc2:
- CMakeList.txt has a custom command for generating eh\_trampoline.S which does not escape
  the compiler flags properly. A patch (or new release of libobjc2) is required.

gnustep-make:
- Configure gnustep-make (and gnustep-base?) to respect the multilib dir standard

gnustep-base:
- Write Systemd .service files for gdnc, and gdomap

Infrastructure:
- Automated builds
- Build Instructions and Fetch Script
