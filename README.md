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

