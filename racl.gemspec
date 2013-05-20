# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'racl/version'

Gem::Specification.new do |gem|
  gem.name          = "racl"
  gem.version       = Racl::VERSION
  gem.authors       = ["peteygao"]
  gem.email         = ["peter@ifeelgoods.com"]
  gem.description   = 'You know, makes people access stuff.'
  gem.summary       = 'Hierarchical User Based Resource Access Control List.'
  gem.homepage      = 'https://github.com/ifeelgoods/hubracl'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
