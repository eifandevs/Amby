# frozen_string_literal: true

source "https://rubygems.org"

gem 'cocoapods', '1.4.0'
gem 'fastlane'
gem 'slather'
gem 'danger'
gem 'danger-swiftlint'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
