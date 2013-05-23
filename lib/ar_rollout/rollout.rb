class Rollout < ActiveRecord::Base
  attr_accessible :name, :group, :user_id, :percentage
  validates :name, presence: true
  validate :validate_one_rollout

  def self.matching(user)
    where('"rollouts".user_id = ? OR "rollouts".user_id IS NULL', user.id).
      where('"rollouts".name NOT IN (SELECT feature FROM "opt_outs" WHERE "opt_outs".user_id = ?)', user.id).uniq_by(&:name).select do |rollout|
        rollout.match? user
      end
  end

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
    else
      data_group = Group.find_by_name(group)
      if data_group && data_group.memberships.where('user_id = ?', user.id).any?
        true
      else
        false
      end
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
