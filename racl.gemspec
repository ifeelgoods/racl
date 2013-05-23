# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'racl/version'

Gem::Specification.new do |gem|
  gem.name          = "racl"
  gem.version       = Racl::VERSION
  gem.authors       = ["peteygao"]
  gem.email         = ["tech@ifeelgoods.com"]
  gem.description   = 'Handles user/role-based access control to defined actions.'
  gem.summary       = 'Ruby Access Control List.'
  gem.homepage      = 'https://github.com/ifeelgoods/racl'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
