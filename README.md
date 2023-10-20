# Packaging modern GNUstep for Linux Distributions (WIP)

This repository hosts dpkg build configuration files for the Debian GNU/Linux distribution.
The goal is to provide a modern, and stable distribution of the GNUstep Objective-C 2.0 Runtime,
Apple's Grand Central Dispatch, GNUstep Makefiles, and GNUstep Base (a.k.a. Foundation).

Please note that the packages are experimental, and not ready for production.

## TODO
Infrastructure:
- Automated builds
- Build Instructions and Fetch Script

## Packages

Option 1: Apple naming scheme

gnustep2.0-base
gnustep2.0-gui
gnustep2.0-make

- libobjc2
	- libobjc2-dev
- libdispatch
	- libdispatch-dev