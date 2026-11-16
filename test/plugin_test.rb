# frozen_string_literal: true

require 'test_helper'

class PluginTest < Minitest::Test
  def test_entry_point_registers_javascript
    assert_includes ActiveScaffold.javascripts, 'active_scaffold_child_memberships'
  end

  def test_entry_point_makes_plugin_modules_available
    assert_equal(
      File.expand_path('../lib/active_scaffold_child_memberships/attribute_params.rb', __dir__),
      ActiveScaffoldChildMemberships::AttributeParams
        .instance_method(:column_value_for_child_memberships_type).source_location.first
    )
    assert_equal(
      File.expand_path('../lib/active_scaffold_child_memberships/helpers.rb', __dir__),
      ActiveScaffoldChildMemberships::Helpers
        .instance_method(:active_scaffold_input_child_memberships).source_location.first
    )
  end

  def test_engine_defines_named_initializers
    assert_equal(
      %w[
        active_scaffold_child_memberships.action_view
        active_scaffold_child_memberships.controller
      ],
      ActiveScaffoldChildMemberships::Engine.initializers.map(&:name)
    )
  end

  def test_action_view_initializer_installs_helpers
    run_initializer('active_scaffold_child_memberships.action_view')

    assert_includes ActionView::Base.ancestors, ActiveScaffoldChildMemberships::Helpers
  end

  def test_controller_initializer_installs_attribute_params
    run_initializer('active_scaffold_child_memberships.controller')

    assert_includes ActiveScaffold::AttributeParams.ancestors,
                    ActiveScaffoldChildMemberships::AttributeParams
  end

  private

  def run_initializer(name)
    ActiveScaffoldChildMemberships::Engine.initializers.find { |initializer| initializer.name == name }.run
  end
end
