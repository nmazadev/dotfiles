#!/usr/bin/env bash
# Full setup of a fresh install: packages, services, config links, login manager.
# Usage: ./bootstrap.sh [--dry-run]
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

./install-packages.sh "$@"
./install-services.sh "$@"
./install.sh "$@"
./install-extras.sh "$@"
