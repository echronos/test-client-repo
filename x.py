#!/usr/bin/env python3
import os.path
import sys
import core.x
core.x.topdir = os.path.normpath(os.path.dirname(__file__))


if __name__ == "__main__":
    sys.exit(core.x.main())
