source 'https://github.com/CocoaPods/Specs.git'
# platform :ios, '14.0'

target 'AudioAndVideoExercises' do
  use_frameworks!

  pod 'Masonry'
  pod 'SDWebImage'
  pod 'AFNetworking'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end