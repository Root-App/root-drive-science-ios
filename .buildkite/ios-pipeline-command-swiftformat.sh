#!/bin/bash
source ~/.bashrc

set -euo pipefail

.buildkite/setup-ios-tests.sh

bin/run-swiftformat --lint --verbose
