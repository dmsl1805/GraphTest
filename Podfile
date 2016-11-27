# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'PromTest' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PromTest
    pod 'MBProgressHUD'
    pod 'Alamofire'
    pod 'UIImage+BlurredFrame'

pod 'CollectionViewWaterfallLayout', :git => 'https://github.com/ostatnicky/CollectionViewWaterfallLayout.git', :branch => 'feature/swift3'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
