# frozen_string_literal: true

require 'yaml'
require 'json'

pipeline = { 'steps' => [] }

secrets_plugin = {
  "seek-oss/aws-sm#v2.1.0" => {
    "env" => {
      "ARTIFACTORY_USER" => {
        "secret-id" => "ARTIFACTORY",
        "json-key" => ".ARTIFACTORY_USER"
      },
      "ARTIFACTORY_PASSWORD" => {
        "secret-id" => "ARTIFACTORY",
        "json-key" => ".ARTIFACTORY_PASSWORD"
      }
    }
  }
}

pipeline['steps'] << {
  'label' => ':swift: iOS tests',
  'command' => '.buildkite/ios-pipeline-command.sh',
  'timeout_in_minutes' => 120,
  'agents' => { 'queue' => 'ios-xcode-11-14-1' },
  'plugins' => secrets_plugin,
  'env' => {
    'DOCKER_PULL_ROOT_SERVER' => 'false'
  }
}

pipeline['steps'] << {
  'label' => ':swift: Swift Format',
  'command' => '.buildkite/ios-pipeline-command-swiftformat.sh',
  'timeout_in_minutes' => 120,
  'agents' => { 'queue' => 'ios-xcode-11-14-1' },
  'plugins' => secrets_plugin,
  'env' => {
    'DOCKER_PULL_ROOT_SERVER' => 'false'
  }
}

puts pipeline.to_yaml
