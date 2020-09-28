# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

#source 'git@github.com:root-app/root-pod-specs.git'
source 'https://github.com/CocoaPods/Specs.git'
plugin 'cocoapods-art', :sources => %w(enterprise-cocoapods)

target 'root-drive-science-ios' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'SwiftFormat/CLI', '0.39.0'

  # Pods for root-drive-science-ios
  # Use this version if you are not also changing code in RootTripTracker
   pod "RootTripTracker", "20200922.0.2"

#  Use this version of the apps if you are working in RootTripTracker
  # pod "RootTripTrackerSource", path: '~/code/root-ios-trip-tracker/RootTripTrackerSource.podspec'


  target 'root-drive-science-iosTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
