# The GNUstep Packaging System
# 
# Copyright (C) 2023 Hugo Melder
# SPDX-License-Identifier: MIT

import argparse

desc = 'Builds the GNUstep Objective-C 2.0 Toolchain for dpkg-based Distributions.'

parser = argparse.ArgumentParser(description=desc)
_ = parser.parse_args()

print("python main function")
