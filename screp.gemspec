# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'screp/version'

Gem::Specification.new do |spec|
  spec.name          = "screp"
  spec.version       = Screp::VERSION
  spec.authors       = ["Miro Koprnicky"]
  spec.email         = ["miro@netsyde.com"]
  spec.description   = %q{Makes nested parsing of html a breeze}
  spec.summary       = %q{A Ruby-based web scraping internal DSL}
  spec.homepage      = "http://rubygems.org/gems/screp"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.required_ruby_version       = '>= 1.9.3'
  spec.add_runtime_dependency        'nokogiri', '~> 1.6'
  spec.add_development_dependency    'rspec', '~> 2.13'
end
