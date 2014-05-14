# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'base_x/version'

Gem::Specification.new do |spec|
  spec.name          = "base_x"
  spec.version       = BaseX::VERSION
  spec.authors       = ["Brian Hempel"]
  spec.email         = ["plasticchicken@gmail.com"]
  spec.summary       = %q{Convert numbers into and out of any base, also allows encoding and decoding binary data. Many bases included.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/brianhempel/base_x"
  spec.license       = "Public Domain"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
