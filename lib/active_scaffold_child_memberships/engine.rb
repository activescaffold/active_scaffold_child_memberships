module ActiveScaffoldChildMemberships
  class Engine < ::Rails::Engine
    initializer 'active_scaffold_kanban.action_view' do
      ActiveSupport.on_load :action_view do
        ActionView::Base.send :include, ActiveScaffoldChildMemberships::Helpers
      end
    end

    initializer 'active_scaffold_kanban.controller' do
      ActiveScaffold::AttributeParams.prepend(ActiveScaffoldChildMemberships::AttributeParams)
    end
  end
end
