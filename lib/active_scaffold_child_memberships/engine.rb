# frozen_string_literal: true

module ActiveScaffoldChildMemberships
  class Engine < ::Rails::Engine
    initializer 'active_scaffold_child_memberships.action_view' do
      ActiveSupport.on_load :action_view do
        ActiveSupport.on_load(:action_view) { include ActiveScaffoldChildMemberships::Helpers }
      end
    end

    initializer 'active_scaffold_child_memberships.controller' do
      ActiveScaffold::AttributeParams.prepend(ActiveScaffoldChildMemberships::AttributeParams)
    end
  end
end
