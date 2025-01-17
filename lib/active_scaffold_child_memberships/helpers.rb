module ActiveScaffoldChildMemberships
  module Helpers
    def active_scaffold_input_child_memberships(column, options, ui_options: column.options)
      raise "#{column.name} should be a has_many through association" unless column.association&.collection? && column.association.through?
      source_col = active_scaffold_config_for(column.association.through_reflection.klass).columns[column.association.source_reflection.name]
      raise "#{column.name}'s through reflection should be a habtm or has_many through association" unless source_col.association.habtm? || source_col.association.collection? && source_col.association.through?
      through_col = active_scaffold_config.columns[column.association.through_reflection.name]
      children = options[:object].send(through_col.name)
      column_records = send(override_helper_per_model(:active_scaffold_child_memberships_members, column.active_record_class), column, children)

      header = column_records.map do |member|
        label = member.send(ui_options[:label_method] || :to_label)
        hidden_field = hidden_field_tag("#{options[:name]}[members][]", member.id, id: nil)
        content_tag(:th, h(label) << hidden_field)
      end
      header.unshift content_tag(:th, through_col.label)

      checkbox_helper = override_helper_per_model(:active_scaffold_child_membership_checkbox, column.active_record_class)
      rows = children.map do |record|
        checkbox_name = "#{options[:name]}[memberships][#{record.id}][]"
        columns = column_records.map.with_index do |member, i|
          content_tag(:td, send(checkbox_helper, column, source_col, record, member, name: checkbox_name, value: i))
        end
        label = record.send(ui_options[:child_label_method] || :to_label)
        columns.unshift content_tag(:td, h(label))
        content_tag(:tr, safe_join(columns), data: {id: record.id})
      end

      hidden_field = hidden_field_tag("#{options[:name]}[members][]", nil, id: nil) if column_records.empty?
      add_label = ui_options[:add_label]
      add_label = :add_column if add_label.nil?
      if add_label
        add_label = as_(add_label, model: source_col.association.klass.model_name.human) if add_label.is_a?(Symbol)
        add_column = link_to(add_label, '#')
        new_column = send(override_helper_per_model(:active_scaffold_child_memberships_new_column, column.active_record_class), column, "#{options[:name]}[members][]", source_col, ui_options)
      end

      content_tag(:table, data: {name: options[:name]}) do
        content_tag(:caption, safe_join([add_column, new_column, hidden_field])) <<
          content_tag(:thead, content_tag(:tr, safe_join(header))) <<
          content_tag(:tbody, safe_join(rows))
      end
    end

    def active_scaffold_child_memberships_members(column, row_records)
      row_records.flat_map(&column.association.source_reflection.name).uniq
    end

    def active_scaffold_child_membership_checkbox(column, source_column, child, member, name:, value:)
      check_box_tag(name, value, child.send(source_column.name).include?(member), id: nil)
    end

    def active_scaffold_child_memberships_new_column(column, name, source_col, ui_options)
      inplace_options = {object: source_col.active_record_class.new, id: '', disabled: true, associated: nil, class: 'inplace_field', name: name}
      form_ui, form_ui_options = ui_options[:add_column_ui]
      ui_method =
        case form_ui
        when :record_select then :active_scaffold_record_select
        when :select, nil then :active_scaffold_input_singular_association
        else
          :"active_scaffold_input_#{form_ui}"
        end
      if form_ui == :record_select
        args = [inplace_options[:object], source_col, inplace_options.merge(js: false), nil, false]
      else
        args = [source_col, inplace_options]
      end
      content_tag(:div, style: 'display:none;', class: inplace_edit_control_css_class) do
        send(ui_method, *args, ui_options: form_ui_options || {})
      end
    end
  end
end
