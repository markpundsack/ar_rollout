class Rollout < ActiveRecord::Base
  def match?(user)
    enabled? && (match_user?(user) || match_group?(user) || match_percentage?(user))
  end

  def enabled?
    failure_count.to_i < 1
  end

  def match_group?(user)
    if Rollout.method_defined? "match_#{group}?"
      send "match_#{group}?", user
    else
      false
    end
  end

  def match_user?(user = nil)
    user_id ? user_id.to_s == user.id.to_s : false
  end

  def match_percentage?(user)
    percentage ? user.id % 100 < percentage : false
  end

end