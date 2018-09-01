# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

def common_pods
  swift_version = "4.0"
  pod 'Realm', '~> 2.4'
  pod 'RealmSwift', '~> 2.4'
  pod 'RxSwift', '~> 4.0'
  pod 'RxCocoa', '~> 4.0'
  pod 'NSObject+Rx', '~> 4.2'
  pod 'Moya/RxSwift', '~> 11.0'
  pod 'SwiftLint', '~> 0.25'
  pod 'SwiftFormat/CLI', '~> 0.33'
end

abstract_target 'All' do

  common_pods

  target 'Qass' do
    use_frameworks!
  
    pod 'VerticalAlignmentLabel', '~> 0.1'
    pod 'R.swift', '~> 4.0'

    target 'Qass-Tests' do
      inherit! :search_paths
    end
  
    target 'Qass-UITests' do
      inherit! :search_paths
    end
  end

  target 'Model' do
  use_frameworks!

    target 'ModelTests' do
      inherit! :search_paths
    end
  end
end
