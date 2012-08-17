require 'ar_rollout/rollout.rb'
require 'ar_rollout/helper.rb'
module ArRollout
  def self.configure
    yield self
  end

  def self.define_group(name, &block)
    Rollout.send :define_method, "match_#{name}?" do |b|
      block.call(b)
    end
  end

  def self.activate_user(feature = nil, user = nil)
    return false if feature.nil? || user.nil?
    res_id = [Fixnum, String].include?(user.class) ? user : user.id
    Rollout.find_or_create_by_name_and_user_id(feature, res_id)
  end

  def self.deactivate_user(feature = nil, user = nil)
    res_id = [Fixnum, String].include?(user.class) ? user : user.id
    Rollout.find_all_by_name_and_user_id(feature, res_id).map(&:destroy)
  end

  def self.activate_group(feature = nil, group = nil)
    return false if feature.nil? || group.nil?
    Rollout.find_or_create_by_name_and_group(feature, group)
  end

  def self.deactivate_group(feature = nil, group = nil)
    Rollout.find_all_by_name_and_group(feature, group).map(&:destroy)
  end

  def self.deactivate_all(feature)
    Rollout.find_all_by_name(feature).map(&:destroy)
  end

  def self.features
    Rollout.select("distinct(name)").order(:name).map(&:name)
  end

  def self.active?(name, user)
    Rollout.where(name: name).any? do |rollout|
      rollout.match?(user)
    end
  end

  def self.degrade_feature(name)
    yield
  rescue StandardError => e
    Rollout.where(name: name).each do |rollout|
      rollout.increment!(:failure_count)
    end
  raise e
end

end

ActionController::Base.send :include, ArRollout::Controller::Helpers

class RolloutTask < Rails::Railtie
  rake_tasks do
    Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
  end
end