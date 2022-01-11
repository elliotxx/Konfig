import os

from diff import process_changed_providers

RELEASE = "release"

if __name__ == '__main__':
    result = process_changed_providers(RELEASE)
