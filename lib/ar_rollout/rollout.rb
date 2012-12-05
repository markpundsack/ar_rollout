class Rollout < ActiveRecord::Base
  attr_accessible :name, :group, :user_id, :percentage
  validates :name, presence: true
  validate :validate_one_rollout

  def match?(user)
    return false unless user
    enabled? && (match_user?(user) || match_group?(user) || match_percentage?(user))
  end

  def enabled?
    failure_count.to_i < 1
  end

  def match_group?(user)
    if Rollout.method_defined? "match_#{group}?"
      send "match_#{group}?", user
    elsif group = Group.find_by_name(group) && group.memberships.where('user_id = ?', user.id).any?
      true
    else
      false
    end
  end

  def match_user?(user)
    user_id ? user_id.to_s == user.id.to_s : false
  end

  def match_percentage?(user)
    percentage ? ((user.id.to_i % 100) < percentage.to_i) : false
  end

  private

  def validate_one_rollout
    unless group || user_id || percentage
      errors.add(:base, 'Must have group, user_id, or percentage')
    end
  end
end
