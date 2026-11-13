# frozen_string_literal: true

require 'test_helper'
require 'bigdecimal'
require 'active_support/core_ext/object/json'
require 'action_view'
require 'active_scaffold_child_memberships/helpers'

# Tests the extracted child-membership rendering helpers.
class HelpersTest < Minitest::Test
  Column = Struct.new(:active_record_class)
  SourceColumn = Struct.new(:name)
  Member = Struct.new(:id)
  Child = Struct.new(:id, :assigned_members) do
    def to_label
      "Child #{id}"
    end
  end

  class Helper < ActionView::Base
    include ActiveScaffoldChildMemberships::Helpers

    def override_helper_per_model(name, _record_class)
      name
    end
  end

  def setup
    lookup_context = ActionView::LookupContext.new([])
    @helper = Helper.with_empty_template_cache.new(lookup_context, {}, nil)
  end

  def test_rows_render_member_checkboxes_with_the_child_scope
    member = Member.new(10)
    child = Child.new(7, [member])
    rows = @helper.send(
      :child_memberships_rows,
      [child],
      [member],
      Column.new(Object),
      SourceColumn.new(:assigned_members),
      'record[children]',
      ui_options: {}
    )

    assert_equal 1, rows.size
    assert_includes rows.first, 'name="record[children][memberships][7][]"'
    assert_includes rows.first, 'value="0"'
    assert_includes rows.first, 'checked="checked"'
    assert_includes rows.first, 'Child 7'
  end

  def test_table_uses_the_supplied_header_cells
    table = @helper.send(:child_memberships_table, 'record[children]', 'Caption', ['Member'], ['Child'])

    assert_includes table, '<caption>Caption</caption>'
    assert_includes table, '<thead><tr>Member</tr></thead>'
    assert_includes table, '<tbody>Child</tbody>'
  end
end
