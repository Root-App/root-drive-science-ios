source "https://rubygems.org"

ruby File.read(File.join(File.dirname(__FILE__), ".ruby-version")).chomp

gem "cocoapods", "1.6.2"
gem "fastlane", "2.116.0"
gem "synx", "0.2.1"
gem "testflight", "1.0.3"
gem "xcode-install", "2.2.0"
gem "xcpretty", "0.3.0"

plugins_path = File.join(File.dirname(__FILE__), "fastlane", "Pluginfile")
if File.exist?(plugins_path)
  eval_gemfile(plugins_path)
end
