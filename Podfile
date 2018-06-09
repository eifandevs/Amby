# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

def common_pods
  swift_version = "4.0"
  pod 'Realm', '~> 2.4'
  pod 'SVProgressHUD', '2.1.2'
  pod 'RealmSwift', '~> 2.4'
  pod 'NVActivityIndicatorView', '~> 4.0.0'
  pod 'RxSwift', '~> 4.0'
  pod 'RxCocoa', '~> 4.0'
  pod 'NSObject+Rx', '~> 4.2'
  pod 'R.swift', '~> 3.3'
  pod 'Alamofire', '~> 4.4'
  pod 'SwiftLint', '~> 0.23'
  pod 'SwiftFormat/CLI', '~> 0.33'
  pod 'KeychainAccess', '~> 3.1'
  pod 'VerticalAlignmentLabel', '~> 0.1'
  pod 'Moya/RxSwift', '~> 11.0'
end

target 'Qass-Develop' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Qass-Develop
  common_pods

  target 'Qass-DevelopTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxSwift', '~> 4.0'
  end

  target 'Qass-DevelopUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end

target 'Qass-Production' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Qass-Production
  common_pods
  
end
