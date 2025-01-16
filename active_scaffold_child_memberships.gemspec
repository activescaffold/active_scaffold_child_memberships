# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'active_scaffold_child_memberships/version'

Gem::Specification.new do |s|
  s.name = %q{active_scaffold_child_memberships}
  s.version = ActiveScaffoldChildMemberships::Version::STRING
  s.platform = Gem::Platform::RUBY
  s.email = %q{activescaffold@googlegroups.com}
  s.authors = ["Sergio Cambra"]
  s.homepage = %q{https://activescaffold.eu}
  s.summary = %q{Form UI :child_memberships for ActiveScaffold}
  s.description = %q{A form UI for ActiveScaffold, allowing to edit membership association for multiple children}
  s.require_paths = ["lib"]
  s.files = `git ls-files -- app config lib`.split("\n") + %w[LICENSE README.md]
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.licenses = ["MIT"]

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.add_runtime_dependency(%q<active_scaffold>, [">= 4.0.0"])
end
