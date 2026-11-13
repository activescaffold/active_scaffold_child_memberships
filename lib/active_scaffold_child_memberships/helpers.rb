# frozen_string_literal: true

module ActiveScaffoldChildMemberships
  module Helpers
    def active_scaffold_input_child_memberships(column, options, ui_options: column.options)
      association = child_memberships_association(column)
      source_col = child_memberships_source_column(column, association)
      through_col = active_scaffold_config.columns[association.through_reflection.name]
      children = options[:object].send(through_col.name)
      column_records = child_memberships_column_records(column, children)
      header_cells = child_memberships_header(column_records, through_col, options[:name], ui_options)
      rows = child_memberships_rows(children, column_records, column, source_col, options[:name], ui_options:)
      caption = child_memberships_caption(column_records, column, source_col, options[:name], ui_options)

      child_memberships_table(options[:name], caption, header_cells, rows)
    end

    def active_scaffold_child_memberships_members(column, row_records)
      row_records.flat_map(&column.association.source_reflection.name).uniq
    end

    def active_scaffold_child_membership_checkbox(column, source_column, child, member, name:, value:)
      check_box_tag(name, value, child.send(source_column.name).include?(member), id: nil)
    end

    def active_scaffold_child_memberships_new_column(column, name, source_col, ui_options)
      inplace_options = {object: source_col.active_record_class.new, id: '', disabled: true, associated: nil,
                         class: 'inplace_field', name: name}
      form_ui, form_ui_options = ui_options[:add_column_ui]
      ui_method =
        case form_ui
        when :record_select then :active_scaffold_record_select
        when :select, nil then :active_scaffold_input_singular_association
        else
          :"active_scaffold_input_#{form_ui}"
        end
      args =
        if form_ui == :record_select
          [inplace_options[:object], source_col, inplace_options.merge(js: false), nil, false]
        else
          [source_col, inplace_options]
        end
      content_tag(:div, style: 'display:none;', class: inplace_edit_control_css_class) do
        send(ui_method, *args, ui_options: form_ui_options || {})
      end
    end

    private

    def child_memberships_association(column)
      association = column.association
      valid_association = association&.collection? && association.through?
      raise "#{column.name} should be a has_many through association" unless valid_association

      association
    end

    def child_memberships_source_column(column, association)
      source_col =
        active_scaffold_config_for(association.through_reflection.klass)
          .columns[association.source_reflection.name]
      source_association = source_col.association
      valid_association =
        source_association.habtm? || (source_association.collection? && source_association.through?)
      unless valid_association
        raise "#{column.name}'s through reflection should be a habtm or has_many through association"
      end

      source_col
    end

    def child_memberships_column_records(column, children)
      helper = override_helper_per_model(:active_scaffold_child_memberships_members, column.active_record_class)
      send(helper, column, children)
    end

    def child_memberships_header(column_records, through_col, name, ui_options)
      header = column_records.map do |member|
        label = member.send(ui_options[:label_method] || :to_label)
        hidden_field = hidden_field_tag("#{name}[members][]", member.id, id: nil)
        content_tag(:th, h(label) << hidden_field)
      end
      header.unshift content_tag(:th, through_col.label)
    end

    def child_memberships_rows(children, column_records, column, source_col, name, ui_options:)
      checkbox_helper = override_helper_per_model(
        :active_scaffold_child_membership_checkbox,
        column.active_record_class
      )
      children.map do |record|
        checkbox_name = "#{name}[memberships][#{record.id}][]"
        columns = column_records.map.with_index do |member, index|
          checkbox = send(checkbox_helper, column, source_col, record, member, name: checkbox_name, value: index)
          content_tag(:td, checkbox)
        end
        label = record.send(ui_options[:child_label_method] || :to_label)
        columns.unshift content_tag(:td, h(label))
        content_tag(:tr, safe_join(columns), data: {id: record.id})
      end
    end

    def child_memberships_caption(column_records, column, source_col, name, ui_options)
      hidden_field = hidden_field_tag("#{name}[members][]", nil, id: nil) if column_records.empty?
      add_column, new_column = child_memberships_add_controls(column, source_col, name, ui_options)
      safe_join([add_column, new_column, hidden_field])
    end

    def child_memberships_add_controls(column, source_col, name, ui_options)
      add_label = ui_options[:add_label]
      add_label = :add_column if add_label.nil?
      return [nil, nil] unless add_label

      add_label = child_memberships_add_label(add_label, source_col)
      new_column_helper = override_helper_per_model(
        :active_scaffold_child_memberships_new_column,
        column.active_record_class
      )
      new_column = send(new_column_helper, column, "#{name}[members][]", source_col, ui_options)
      [link_to(add_label, '#'), new_column]
    end

    def child_memberships_add_label(add_label, source_col)
      return add_label unless add_label.is_a?(Symbol)

      as_(add_label, model: source_col.association.klass.model_name.human)
    end

    def child_memberships_table(name, caption, header_cells, rows)
      content_tag(:table, data: {name: name}) do
        content_tag(:caption, caption) <<
          content_tag(:thead, content_tag(:tr, safe_join(header_cells))) <<
          content_tag(:tbody, safe_join(rows))
      end
    end
  end
end
