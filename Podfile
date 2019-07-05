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
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'GoogleSignIn'

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

post_install do |installer|
    installer.aggregate_targets.each do |aggregate_target|
        puts aggregate_target.name
        if aggregate_target.name != 'Pods-Model'
            aggregate_target.xcconfigs.each do |config_name, config_file|
                config_file.frameworks.delete('FirebaseAuth')
                config_file.frameworks.delete('FirebaseCore')
                config_file.frameworks.delete('FirebaseInstanceID')
                config_file.frameworks.delete('FirebaseAnalytics')
                config_file.frameworks.delete('FirebaseCoreDiagnostics')
                config_file.frameworks.delete('FIRAnalyticsConnector')
                config_file.frameworks.delete('GTMSessionFetcher')
                config_file.frameworks.delete('GoogleSignIn')
                config_file.frameworks.delete('GoogleAppMeasurement')
                config_file.frameworks.delete('GoogleToolboxForMac')
                config_file.frameworks.delete('GoogleUtilities')
                config_file.frameworks.delete('nanopb')

                xcconfig_path = aggregate_target.xcconfig_path(config_name)
                config_file.save_as(xcconfig_path)
            end
        end
    end
end
