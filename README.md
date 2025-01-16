# ChildMemberships Form UI for ActiveScaffold

An addon for ActiveScaffold adding :child_memberships form_ui.

It requires ActiveScaffold 4.0, and RecordSelect 4.0.2 if want to use :recordselect to add new columns.

## Usage

ActiveScaffold allows to edit memberships on one record with :select form_ui, for either has_and_belongs_to_many, or has_many through. For example, using :select in :roles column with any of these examples would work in the same way:

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :roles
end

class User < ApplicationRecord
  has_many :role_memberships
  has_many :roles, through: :role_memberships
end

class RoleMembership < ApplicationRecord
  belongs_to :user
  belongs_to :role
end
```

But sometimes you may have User model grouped in other model, with has_many association, and may want to edit memberships for all the users in the group.

```ruby
class Group < ApplicationRecord
  has_many :users
end
```

This form_ui :child_memberships can be used in a :roles has_many through association:

```ruby
class Group < ApplicationRecord
  has_many :users
  has_many :roles, through: :users
end
class GroupsController < ApplicationController
  active_scaffold :group do |conf|
    conf.update.columns = [:name, :roles]
    conf.columns[:roles].form_ui = :child_memberships
  end
end
```

Then you get a table, with all users in the group in the rows, and roles in the columns. Only the assigned roles are in the columns by default, and new column can be added with a select tag to pick a new role to assign to users:

![image](https://github.com/user-attachments/assets/793b07bd-b7bf-4336-a319-b40136cdb5e8)

The form_ui used to select the record of the new columns can be changed, with options for the form_ui (or column's options), with the key `:add_column_ui`, for example to use RecordSelect:

```ruby
    conf.columns[:roles].form_ui = :child_memberships, {add_column_ui: :record_select}
```

If no form_ui is defined with `:add_column_ui`, it defaults to `:select`. If ui options must be passed to the form_ui, they can be added using an array with the form UI and the options hash:

```ruby
    conf.columns[:roles].form_ui = :child_memberships, {add_column_ui: [:select, {include_blank: 'Pick one'}]}
```

The method used for the label in the rows is defined with `:label_method`, defaults to `:to_label`. For example, to use `short_name` method of Role model:

```ruby
    conf.columns[:roles].form_ui = :child_memberships, {label_method: :short_name}
```

The method used for the label in the rows is defined with `:child_label_method`, defaults to `:to_label`. For example, to use `first_name` method of User model:

```ruby
    conf.columns[:roles].form_ui = :child_memberships, {child_label_method: :first_name}
```

The label of the link to add a new column uses `:add_label` translation key, in the `:active_scaffold` scope. It can be changed to a string, skipping the translation, or other symbol to use other translation key, in the `:active_scaffold` scope. The translation can use `%{model}` variable to display the name of the associated model.

```ruby
    conf.columns[:roles].form_ui = :child_memberships, {add_label: 'Add other role'}
```

If new columns are not allowed, it can be disabled using `add_label: false`:

```ruby
    conf.columns[:roles].form_ui = :child_memberships, {add_label: false}
```
