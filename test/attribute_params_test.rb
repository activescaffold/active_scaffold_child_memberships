# frozen_string_literal: true

require 'test_helper'

# Tests conversion and dispatch of submitted child membership parameters.
class AttributeParamsTest < Minitest::Test
  Member = Struct.new(:id)
  Child = Struct.new(:id)
  Reflection = Struct.new(:name, :klass)
  Association = Struct.new(:klass, :through_reflection, :source_reflection)
  Column = Struct.new(:form_ui, :association)
  Config = Struct.new(:columns)

  class MemberRepository
    class << self
      attr_accessor :records

      def find(ids)
        records.values_at(*ids)
      end
    end
  end

  class Parent
    attr_reader :children

    def initialize(children)
      @children = children
    end
  end

  class BaseUpdater
    attr_reader :calls

    def initialize
      @calls = []
    end

    def update_column_association(*arguments, **options)
      @calls << [arguments, options]
    end
  end

  class Updater < BaseUpdater
    prepend ActiveScaffoldChildMemberships::AttributeParams

    attr_accessor :associated_config

    def active_scaffold_config_for(_klass)
      associated_config
    end

    def update_association(...)
      update_column_association(...)
    end

    def membership_values(...)
      column_value_for_child_memberships_type(...)
    end
  end

  def setup
    @first_member = Member.new(10)
    @second_member = Member.new(20)
    MemberRepository.records = {'10' => @first_member, '20' => @second_member}
    @first_child = Child.new(1)
    @second_child = Child.new(2)
    @association = Association.new(
      MemberRepository,
      Reflection.new(:children, Object),
      Reflection.new(:members, nil)
    )
    @column = Column.new(:child_memberships, @association)
    @updater = Updater.new
  end

  def test_converts_member_indexes_to_records_for_each_child
    values = {
      members: ['', '10', '20'],
      memberships: {'1' => ['', '1'], '2' => ['2']}
    }

    result = @updater.membership_values(Parent.new([@first_child, @second_child]), @column, values)

    assert_equal [
      [@first_child, [@first_member]],
      [@second_child, [@second_member]]
    ], result
  end

  def test_converts_missing_child_memberships_to_an_empty_collection
    values = {members: ['', '10'], memberships: {}}

    result = @updater.membership_values(Parent.new([@first_child]), @column, values)

    assert_equal [[@first_child, []]], result
  end

  def test_dispatches_each_child_to_the_source_association
    source_column = Column.new(:select, nil)
    @updater.associated_config = Config.new({members: source_column})
    values = {@first_child => [@first_member], @second_child => [@second_member]}

    @updater.update_association(Object.new, @column, :members, values, nested: true)

    assert_equal [
      [[@first_child, source_column, :members, [@first_member]], {nested: true}],
      [[@second_child, source_column, :members, [@second_member]], {nested: true}]
    ], @updater.calls
  end
end
