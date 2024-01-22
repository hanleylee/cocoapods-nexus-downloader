# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-maven/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-maven'
  spec.version       = CocoapodsMaven::VERSION
  spec.authors       = ['Hanley Lee']
  spec.email         = ['hanley.lei@gmail.com']
  spec.description   = %q{Host the pod's framework file on Maven and download it using ':maven'.}
  spec.summary       = %q{A CocoaPods plugin that enables referencing a pod using ':maven' and downloading it from Maven.}
  spec.homepage      = 'https://github.com/hanleylee/cocoapods-maven'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
