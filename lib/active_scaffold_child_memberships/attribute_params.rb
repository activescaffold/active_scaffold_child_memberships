# frozen_string_literal: true

module ActiveScaffoldChildMemberships
  module AttributeParams
    protected

    def update_column_association(parent_record, column, attribute, value, ...)
      if column.form_ui == :child_memberships
        source_col =
          active_scaffold_config_for(column.association.through_reflection.klass)
            .columns[column.association.source_reflection.name]
        value.each do |child, members|
          update_column_association(child, source_col, attribute, members, ...)
        end
      else
        super
      end
    end

    def column_value_for_child_memberships_type(parent_record, column, value)
      ids = value[:members].compact_blank
      members = column.association.klass.find(ids)&.index_by { |member| member.id.to_s }
      parent_record.send(column.association.through_reflection.name).map do |child|
        ids = value.dig(:memberships, child.id.to_s)&.select(&:present?)&.map(&:to_i)
        member_ids = value[:members].values_at(*ids).compact_blank
        [child, members.values_at(*member_ids)]
      end
    end
  end
end
