# The GNUstep Packaging System
# 
# Copyright (C) 2023 Hugo Melder
# SPDX-License-Identifier: MIT

import json

from enum import Enum

class Architecture(Enum):
    X86_64 = "x86_64"
    AARCH64 = "aarch64"

class Platform(Enum):
    DEBIAN = "debian"
    UBUNTU = "ubuntu"

class OperatingSystem(Enum):
    LINUX = "linux"
    WINDOWS = "windows"


class Distribution:
    def __init__(self, friendly_name, name, platform, packaging, config_path, patches):
        self.friendly_name = friendly_name
        self.name = name
        self.platform = platform
        self.packaging = packaging
        self.config_path = config_path
        self.patches = patches

    @classmethod
    def from_dict(cls, data):
        return cls(data['friendly_name'], data['name'], data['platform'], data['packaging'], data['config_path'], data['patches'])

class Metadata:
    def __init__(self, name, tag, git, dist):
        self.name = name
        self.tag = tag
        self.git = git
        self.dist = [Distribution.from_dict(d) for d in dist]

    @classmethod
    def from_json(cls, json_str):
        data = json.loads(json_str)
        return cls(data['name'], data['tag'], data['git'], data['dist'])

    @staticmethod
    def parse_json(json_str):
        data = json.loads(json_str)
        return Metadata.from_dict(data)