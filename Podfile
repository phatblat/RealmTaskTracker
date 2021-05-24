project 'RealmTaskTracker.xcodeproj'

platform :ios, '14.0'
inhibit_all_warnings!

target 'RealmTaskTracker' do
  use_frameworks!

  # https://github.com/realm/realm-cocoa/releases
  pod 'RealmSwift', '~> 10.7.6'

  target 'RealmTaskTrackerTests' do
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble'
  end

  target 'RealmTaskTrackerUITests' do
  end
end
