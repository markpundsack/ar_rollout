class Membership < ActiveRecord::Base
  set_table_name :groups_users

  belongs_to :group
  belongs_to :user
end
