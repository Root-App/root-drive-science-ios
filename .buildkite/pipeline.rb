# frozen_string_literal: true

require 'yaml'
require 'json'

pipeline = { 'steps' => [] }

pipeline['steps'] << {
  'label' => ':swift: iOS tests',
  'command' => '.buildkite/ios-pipeline-command.sh',
  'timeout_in_minutes' => 120,
  'agents' => { 'queue' => 'ios-13' },
  'env' => {
    'DOCKER_PULL_ROOT_SERVER' => 'false'
  }
}

pipeline['steps'] << {
  'label' => ':swift: Swift Format',
  'command' => '.buildkite/ios-pipeline-command-swiftformat.sh',
  'timeout_in_minutes' => 120,
  'agents' => { 'queue' => 'ios-13' },
  'env' => {
    'DOCKER_PULL_ROOT_SERVER' => 'false'
  }
}

puts pipeline.to_yaml
