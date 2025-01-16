require 'active_scaffold_child_memberships/engine'
require 'active_scaffold_child_memberships/version'

module ActiveScaffoldChildMemberships
  autoload :AttributeParams, 'active_scaffold_child_memberships/attribute_params'
  autoload :Helpers, 'active_scaffold_child_memberships/helpers'
end
ActiveScaffold.javascripts << 'active_scaffold_child_memberships'
