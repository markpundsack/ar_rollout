require 'ar_rollout/rollout.rb'
require 'ar_rollout/group.rb'
require 'ar_rollout/membership.rb'
require 'ar_rollout/helper.rb'
module ArRollout
  @@defined_groups = []

  def self.configure
    yield self
  end

  def self.defined_groups
    @@defined_groups
  end

  def self.groups
    (@@defined_groups + Group.select(:name).collect(&:name).collect(&:intern)).uniq.sort
  end

  def self.define_group(name, &block)
    @@defined_groups << name

    Rollout.send :define_method, "match_#{name}?" do |b|
      block.call(b)
    end
  end

  def self.activate_user(feature, user)
    return false if feature.nil? || user.nil?
    res_id = [Fixnum, String].include?(user.class) ? user : user.id
    Rollout.find_or_create_by_name_and_user_id(feature, res_id)
  end

  def self.deactivate_user(feature, user)
    res_id = [Fixnum, String].include?(user.class) ? user : user.id
    Rollout.find_all_by_name_and_user_id(feature, res_id).map(&:destroy)
  end

  def self.activate_group(feature, group)
    return false if feature.nil? || group.nil?
    Rollout.find_or_create_by_name_and_group(feature, group)
  end

  def self.deactivate_group(feature, group)
    Rollout.find_all_by_name_and_group(feature, group).map(&:destroy)
  end

  def self.activate_percentage(feature, percentage)
    Rollout.where("name = ? and percentage is not null", feature).destroy_all
    Rollout.create(name: feature, percentage: percentage)
  end

  def self.deactivate_all(feature)
    Rollout.find_all_by_name(feature).map(&:destroy)
  end

  def self.features
    Rollout.select("distinct(name)").order(:name).map(&:name)
  end

  def self.active?(name, user)
    return false unless user
    Rollout.where(name: name).where("user_id = ? or user_id is NULL", user.id.to_i).any? do |rollout|
      rollout.match?(user)
    end
  end

  def self.all_active(user)
    return false unless user
    rollouts = []
    Rollout.where("user_id = ? or user_id is NULL", user.id.to_i).each do |rollout|
      rollouts << rollout.name if rollout.match?(user)
    end
    rollouts.uniq
  end

  def self.degrade_feature(name)
    yield
  rescue StandardError => e
    Rollout.where(name: name).each do |rollout|
      rollout.increment!(:failure_count)
    end
    raise e
  end

  def self.info(feature)
    {
      :percentage => (active_percentage(feature) || 0).to_i,
      :groups => active_groups(feature).map { |g| g.to_sym },
      :users => active_user_ids(feature)
    }
  end

private
   def self.active_groups(feature)
    Rollout.where('"name" = ? and "group" is not null', feature).map(&:group)
  end

  def self.active_user_ids(feature)
    Rollout.where('"name" = ? and "user_id" is not null', feature).map(&:user_id)
  end

  def self.active_percentage(feature)
    Rollout.select("percentage").where('"name" = ? and "percentage" is not null', feature).first
  end

end

ActionController::Base.send :include, ArRollout::Controller::Helpers

class RolloutTask < Rails::Railtie
  rake_tasks do
    Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
  end
end
