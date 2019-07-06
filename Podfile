# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'Amby' do
  use_frameworks!
#    inhibit_all_warnings!

  pod 'SwiftFormat/CLI'
  pod 'SwiftLint', '~> 0.25'
  pod 'VerticalAlignmentLabel', '~> 0.1'
  pod 'R.swift', '~> 4.0'
  pod 'RxSwift', '~> 4.0'
  pod 'RxCocoa', '~> 4.0'
  pod 'NSObject+Rx', '~> 4.2'
  pod 'LicensePlist', '~> 1.8'
  pod 'SmileLock', '~> 3.0'
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'GoogleSignIn'
end

target 'Model' do
  use_frameworks!
#    inhibit_all_warnings!

  pod 'SwiftFormat/CLI'
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
end

target 'Entity' do
  use_frameworks!
end

target 'CommonUtil' do
  use_frameworks!
end