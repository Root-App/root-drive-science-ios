#!/bin/bash
source ~/.bashrc

bundle install
./bin/run-synx.sh
echo "checking synx diff"

set +e pipefail
git diff --quiet
diff_exit_code=$?
if [ $diff_exit_code -eq 0 ]
then
  echo "success: synx diff empty"
else
  echo "failure: synx diff not empty"
  echo "ensure ./bin/run-synx.sh was run after project changes"
  exit $diff_exit_code
fi


# No tests yet
# set -e pipefail

# bundle exec pod repo update
# bundle exec pod install

# bundle install
# bundle exec ./bin/test.sh unit
