# The GNUstep Packaging System
# 
# Copyright (C) 2023 Hugo Melder
# SPDX-License-Identifier: MIT

from metadata import Metadata, Distribution;

class Fetch:
    def __init__(self, metadataList):
        self.metadataList =  metadataList

    def fetch(self):
        print("fetching")

    def fetch_all(self):
        print("fetching all")