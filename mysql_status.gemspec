# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mysql_status/version'

Gem::Specification.new do |spec|
  spec.name          = "mysql_status"
  spec.version       = MysqlStatus::VERSION
  spec.authors       = ["mizokami"]
  spec.email         = ["suzunatsu@yahoo.com"]
  spec.summary       = %q{MySQL STATUS}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord"
  spec.add_dependency "activesupport"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
