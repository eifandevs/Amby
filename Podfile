# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

def common_pods
  swift_version = "4.0"
  pod 'SwiftFormat/CLI', '~> 0.33'
end

abstract_target 'All' do

  common_pods

  target 'Amby' do
    use_frameworks!
#    inhibit_all_warnings!
  
    pod 'SwiftLint', '~> 0.25'
    pod 'VerticalAlignmentLabel', '~> 0.1'
    pod 'R.swift', '~> 4.0'
    pod 'RxSwift', '~> 4.0'
    pod 'RxCocoa', '~> 4.0'
    pod 'NSObject+Rx', '~> 4.2'
    pod 'LicensePlist', '~> 1.8'
    pod 'Firebase/Core', '~> 5.9'
    pod 'Firebase/AdMob', '~> 5.9'
    pod 'Fabric', '~> 1.7.11'
    pod 'Crashlytics', '~> 3.10.7'
    pod 'SmileLock', '~> 3.0'

    target 'Amby-UITests' do
      inherit! :search_paths
    end
  end

  target 'Model' do
    use_frameworks!
#    inhibit_all_warnings!

    pod 'RxSwift', '~> 4.0'
    pod 'RxCocoa', '~> 4.0'
    pod 'NSObject+Rx', '~> 4.2'
    pod 'Moya/RxSwift', '~> 11.0'
    pod 'GithubAPI', '~> 0.0.5'

    target 'ModelTests' do
      inherit! :search_paths
    end
  end

  target 'Logger' do
    use_frameworks!
#    inhibit_all_warnings!
  
    target 'LoggerTests' do
      inherit! :search_paths
    end
  end

  target 'Entity' do
    use_frameworks!
#    inhibit_all_warnings!
  end
end
