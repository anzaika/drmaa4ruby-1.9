# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "drmaa/version"

Gem::Specification.new do |s|
  s.name        = "drmaa"
  s.version     = DRMAA::VERSION
  s.authors     = ["Andreas Haas", "Jeremy Lipson"]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = %q{drmaa interface for ruby}
  s.description = %q{}

  s.rubyforge_project = "drmaa4ruby"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Development dependencies
  # s.add_development_dependency "rspec"

  # Runtime dependencies
  s.add_runtime_dependency "ffi"

end
