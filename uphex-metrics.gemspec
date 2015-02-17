# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'uphex/metrics/version'

Gem::Specification.new do |spec|
  spec.name          = "uphex-metrics"
  spec.version       = UpHex::Metrics::VERSION
  spec.authors       = ["John Feminella"]
  spec.email         = ["jxf@jxf.me"]
  spec.summary       = "Tools for working with metrics and time series data."
  spec.description   = spec.summary
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.extensions << "ext/check_dependencies/extconf.rb"

  spec.add_runtime_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
