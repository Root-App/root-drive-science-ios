#!/bin/bash
source ~/.bashrc

set -euo pipefail

bundle install

bundle exec pod repo update
bundle exec pod install

bin/run-swiftformat --lint --verbose
