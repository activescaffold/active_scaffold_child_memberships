# frozen_string_literal: true

require 'test_helper'
require 'bigdecimal'
require 'active_support/core_ext/object/json'
require 'action_view'
require 'active_scaffold_child_memberships/helpers'

# Tests the extracted child-membership rendering helpers.
class HelpersTest < Minitest::Test
  Column = Struct.new(:active_record_class, :association, :name, :options)
  SourceColumn = Struct.new(:name, :active_record_class, :association)
  Reflection = Struct.new(:name, :klass)
  Association = Struct.new(:source_reflection, :through_reflection, :collection, :through) do
    def collection?
      collection
    end

    def through?
      through
    end
  end
  SourceAssociation = Struct.new(:kind, :klass) do
    def habtm?
      kind == :habtm
    end

    def collection?
      kind == :collection
    end

    def through?
      kind == :through
    end
  end
  Member = Struct.new(:id) do
    def to_label
      "Member #{id}"
    end
  end
  Child = Struct.new(:id, :assigned_members) do
    def to_label
      "Child #{id}"
    end
  end

  class Helper < ActionView::Base
    include ActiveScaffoldChildMemberships::Helpers

    attr_accessor :associated_config, :active_scaffold_config_data

    def override_helper_per_model(name, _record_class)
      name
    end

    def active_scaffold_config_for(_klass)
      associated_config
    end

    def active_scaffold_config
      active_scaffold_config_data
    end

    def inplace_edit_control_css_class
      'inplace-control'
    end

    def active_scaffold_input_singular_association(_column, options, ui_options:)
      "singular:#{options[:name]}:#{ui_options[:prompt]}"
    end

    def active_scaffold_record_select(_record, _column, options, _value, _multiple, ui_options:)
      "record-select:#{options[:name]}:#{options[:js]}:#{ui_options[:prompt]}"
    end

    def as_(key, model:)
      "#{key}:#{model}"
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

  def test_input_builds_the_complete_membership_table
    member = Member.new(10)
    child = Child.new(7, [member])
    through_column = Struct.new(:name, :label).new(:children, 'Children')
    source_column = SourceColumn.new(
      :assigned_members,
      Member,
      SourceAssociation.new(:habtm, Member)
    )
    association = Association.new(
      Reflection.new(:assigned_members, nil),
      Reflection.new(:children, Object),
      true,
      true
    )
    column = Column.new(Object, association, :members, {})
    @helper.active_scaffold_config_data = Struct.new(:columns).new({children: through_column})
    @helper.associated_config = Struct.new(:columns).new({assigned_members: source_column})
    parent = Struct.new(:children).new([child])

    html = @helper.active_scaffold_input_child_memberships(
      column,
      {object: parent, name: 'record[members]'},
      ui_options: {add_label: false}
    )

    assert_includes html, '<table'
    assert_includes html, 'Children'
    assert_includes html, 'value="10"'
    assert_includes html, 'data-id="7"'
  end

  def test_table_uses_the_supplied_header_cells
    table = @helper.send(:child_memberships_table, 'record[children]', 'Caption', ['Member'], ['Child'])

    assert_includes table, '<caption>Caption</caption>'
    assert_includes table, '<thead><tr>Member</tr></thead>'
    assert_includes table, '<tbody>Child</tbody>'
  end

  def test_members_are_flattened_and_deduplicated
    first = Member.new(1)
    second = Member.new(2)
    column = Column.new(Object, Struct.new(:source_reflection).new(Reflection.new(:assigned_members, nil)))
    children = [Child.new(1, [first, second]), Child.new(2, [first])]

    assert_equal [first, second], @helper.active_scaffold_child_memberships_members(column, children)
  end

  def test_membership_checkbox_reflects_assignment
    member = Member.new(1)
    child = Child.new(2, [member])
    source_column = SourceColumn.new(:assigned_members)

    html = @helper.active_scaffold_child_membership_checkbox(
      Column.new,
      source_column,
      child,
      member,
      name: 'members[]',
      value: 3
    )

    assert_includes html, 'name="members[]"'
    assert_includes html, 'value="3"'
    assert_includes html, 'checked="checked"'
    assert_not_includes html, 'id='
  end

  def test_association_must_be_a_has_many_through
    invalid = Column.new(Object, Association.new(nil, nil, true, false), :members)

    error = assert_raises(RuntimeError) { @helper.send(:child_memberships_association, invalid) }

    assert_equal 'members should be a has_many through association', error.message
  end

  def test_source_association_must_be_habtm_or_has_many_through
    through_class = Class.new
    association = Association.new(
      Reflection.new(:members, nil),
      Reflection.new(:children, through_class),
      true,
      true
    )
    column = Column.new(Object, association, :members)
    source_column = SourceColumn.new(:members, Object, SourceAssociation.new(:singular, Object))
    @helper.associated_config = Struct.new(:columns).new({members: source_column})

    error = assert_raises(RuntimeError) do
      @helper.send(:child_memberships_source_column, column, association)
    end

    assert_equal "members's through reflection should be a habtm or has_many through association", error.message
  end

  def test_source_column_accepts_habtm_association
    association = Association.new(
      Reflection.new(:members, nil),
      Reflection.new(:children, Object),
      true,
      true
    )
    column = Column.new(Object, association, :members)
    source_column = SourceColumn.new(:members, Object, SourceAssociation.new(:habtm, Object))
    @helper.associated_config = Struct.new(:columns).new({members: source_column})

    assert_same source_column, @helper.send(:child_memberships_source_column, column, association)
  end

  def test_new_column_uses_singular_association_by_default
    source_column = SourceColumn.new(:member, Class.new, nil)

    html = @helper.active_scaffold_child_memberships_new_column(
      Column.new,
      'record[members][]',
      source_column,
      {add_column_ui: [nil, {prompt: 'Choose'}]}
    )

    assert_includes html, 'style="display:none;"'
    assert_includes html, 'class="inplace-control"'
    assert_includes html, 'singular:record[members][]:Choose'
  end

  def test_new_column_supports_record_select
    source_column = SourceColumn.new(:member, Class.new, nil)

    html = @helper.active_scaffold_child_memberships_new_column(
      Column.new,
      'record[members][]',
      source_column,
      {add_column_ui: [:record_select, {prompt: 'Search'}]}
    )

    assert_includes html, 'record-select:record[members][]:false:Search'
  end

  def test_caption_has_empty_member_marker_and_can_hide_add_controls
    html = @helper.send(
      :child_memberships_caption,
      [],
      Column.new,
      SourceColumn.new,
      'record[children]',
      {add_label: false}
    )

    assert_includes html, 'name="record[children][members][]"'
    assert_not_includes html, '<a'
  end

  def test_literal_add_label_is_returned_unchanged
    assert_equal 'Add member', @helper.send(:child_memberships_add_label, 'Add member', SourceColumn.new)
  end
end
