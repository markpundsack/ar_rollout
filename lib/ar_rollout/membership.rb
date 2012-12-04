class Membership < ActiveRecord::Base
  self.table_name = :groups_users

  attr_accessible :group_id, :user_id

  belongs_to :group
  belongs_to :user

  validates :user_id, :group_id, presence: true
end
