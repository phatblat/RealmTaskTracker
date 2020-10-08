project 'RealmTaskTracker.xcodeproj'

platform :ios, '13.0'
inhibit_all_warnings!

target 'RealmTaskTracker' do
  use_frameworks!

  # https://github.com/realm/realm-cocoa/releases/tag/v10.0.0-rc.1
  pod 'RealmSwift', '10.0.0-rc.1'

  target 'RealmTaskTrackerTests' do
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble'
  end

  target 'RealmTaskTrackerUITests' do
  end
end
