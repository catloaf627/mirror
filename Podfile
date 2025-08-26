# Define the minimum iOS version for the whole project.
# This prevents Xcode from trying to link old, removed libraries (like libarclite).
platform :ios, '12.0'

target 'Mirror' do
  # Use dynamic frameworks instead of static libraries.
  # Most modern pods need this.
  use_frameworks!

  # Add your pods here ↓
  pod 'Masonry', '~> 1.1'
end

# --- Why this block is needed ---
# Some older pods (like Masonry) still declare an ancient deployment target (e.g. iOS 8).
# Xcode 15+ no longer supports that and errors with:
# "SDK does not contain 'libarclite' ... try increasing the minimum deployment target."
#
# This post_install block force-updates every Pod target to use iOS 12.0 (or newer).
# Without this, Masonry will still try to build for iOS 8 and fail.
post_install do |installer|
  installer.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
