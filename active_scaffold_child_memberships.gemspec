# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'active_scaffold_child_memberships/version'

Gem::Specification.new do |s|
  s.name = 'active_scaffold_child_memberships'
  s.version = ActiveScaffoldChildMemberships::Version::STRING
  s.platform = Gem::Platform::RUBY
  s.email = 'activescaffold@googlegroups.com'
  s.authors = ['Sergio Cambra']
  s.homepage = 'https://activescaffold.eu'
  s.summary = 'Form UI :child_memberships for ActiveScaffold'
  s.description = 'A form UI for ActiveScaffold, allowing to edit membership association for multiple children'
  s.require_paths = ['lib']
  s.files = `git ls-files -- app config lib`.split("\n") + %w[LICENSE README.md]
  s.extra_rdoc_files = [
    'README.md'
  ]
  s.licenses = ['MIT']

  s.required_ruby_version = '>= 3.2'

  s.add_dependency('active_scaffold', ['>= 4.4.0'])
  s.metadata['rubygems_mfa_required'] = 'true'
end
