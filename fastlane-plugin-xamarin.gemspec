# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/xamarin/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-xamarin'
  spec.version       = Fastlane::Xamarin::VERSION
  spec.author        = %q{Thomas Charriere}
  spec.email         = %q{git@a.charri.ch}

  spec.summary       = %q{Build Xamarin Android + iOS projects}
  spec.homepage      = "https://github.com/charri/fastlane-plugin-xamarin"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency 'your-dependency', '~> 1.0.0'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'fastlane', '>= 2.28.3'
end
