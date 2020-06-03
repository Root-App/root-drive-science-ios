#!/bin/bash
source ~/.bashrc

export COCOAPODS_ART_NETRC_PATH=/tmp/$(uuidgen).netrc

cleanup_temp_netrc() {
  rm $COCOAPODS_ART_NETRC_PATH
}

setup_ios_tests() {
  set -eou pipefail

  trap cleanup_temp_netrc EXIT INT TERM
  bundle install

  echo "Writing temporary netrc file to $COCOAPODS_ART_NETRC_PATH"
  echo "machine joinroot.jfrog.io login $ARTIFACTORY_USER password $ARTIFACTORY_PASSWORD" > $COCOAPODS_ART_NETRC_PATH

  set +e pipefail
  repos=$(bundle exec pod repo-art list | grep enterprise-cocoapods)
  set -e pipefail

  if [[ ${#repos} -eq 0 ]]; then
    echo "Adding enterprise-cocoapods artifactory repo"
    bundle exec pod repo-art add enterprise-cocoapods "https://joinroot.jfrog.io/artifactory/api/pods/enterprise-cocoapods"
  else
    echo "Updating enterprise-cocoapods artifactory repo"
    bundle exec pod repo-art update enterprise-cocoapods
  fi

  bundle exec pod repo update
  bundle exec pod install
}

setup_ios_tests
