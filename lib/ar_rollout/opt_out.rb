class OptOut < ActiveRecord::Base
  validates_uniqueness_of :user_id, scope: :feature
  validates :user_id, :feature, presence: true
  attr_accessible :user_id, :feature
end
