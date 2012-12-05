require 'ar_rollout/rollout.rb'
require 'ar_rollout/group.rb'
require 'ar_rollout/membership.rb'
require 'ar_rollout/opt_out.rb'
require 'ar_rollout/helper.rb'

module ArRollout
  @@defined_groups = []
  @@scanned_features = nil

  def self.configure
    yield self
  end

  def self.activate_user(feature, user)
    permit_user(feature, user)
    Rollout.find_or_create_by_name_and_user_id!(feature, get_id(user))
  end

  def self.deactivate_user(feature, user)
    Rollout.find_all_by_name_and_user_id(feature, get_id(user)).each(&:destroy)
  end

  def self.omit_user(feature, user)
    OptOut.find_or_create_by_feature_and_user_id!(feature, get_id(user))
  end

  def self.permit_user(feature, user)
    OptOut.find_by_feature_and_user_id(feature, get_id(user)).try(:destroy)
  end

  def self.activate_group(feature, group)
    unless defined_groups.include?(group) || Group.find_by_name(group)
      Group.create!(name: group)
    end

    Rollout.find_or_create_by_name_and_group!(feature, group)
  end

  def self.deactivate_group(feature, group)
    Rollout.find_all_by_name_and_group(feature, group).each(&:destroy)
  end

  def self.activate_percentage(feature, percentage)
    Rollout.where(name: feature).where('"percentage" IS NOT NULL').each(&:destroy)
    Rollout.create!(name: feature, percentage: percentage)
  end

  def self.deactivate_percentage(feature)
    Rollout.where(name: feature).where('"percentage" IS NOT NULL').each(&:destroy)
  end

  def self.deactivate(feature)
    Rollout.where(name: feature).destroy_all
    OptOut.where(feature: feature).destroy_all
  end

  def self.data_groups
    Group.all
  end

  def self.defined_groups
    @@defined_groups
  end

  def self.groups
    (defined_groups + data_groups.collect(&:name).collect(&:intern)).uniq.sort
  end

  def self.active_groups
    Rollout.where('"group" IS NOT NULL').collect(&:group).uniq.sort
  end

  def self.get_group(group)
    Group.find_or_create_by_name!(group) unless defined_groups.include?(group.intern)
  end

  def self.create_group(group)
    get_group(group)
  end

  def self.change_group_name(old_name, new_name)
    if group = Group.find_by_name(old_name)
      group.update_attributes!(name: new_name)
      Rollout.find_all_by_group(old_name).each { |rollout| rollout.update_attributes!(group: new_name) }
    end
  end

  def self.add_user_to_group(group, user)
    Membership.find_or_create_by_group_id_and_user_id!(get_group(group).id, get_id(user))
  end

  def self.remove_user_from_group(group, user)
    Membership.find_by_group_id_and_user_id(get_group(group).id, get_id(user)).try(&:destroy)
  end

  def self.delete_group(group)
    Group.find_by_name(group).try(:destroy)
  end

  def self.define_group(name, &block)
    @@defined_groups << name

    Rollout.send :define_method, "match_#{name}?" do |b|
      block.call(b)
    end
  end

  def self.features
    scanned_feature_names = scanned_features.collect { |scanned_feature| scanned_feature[0] }
    Rollout.select('distinct("name")').where('"name" not in (?)', scanned_feature_names).inject(scanned_feature_names) do |arr, rollout|
      arr << rollout.name
    end.sort
  end

  def self.active?(name, user)
    return false unless user
    unless OptOut.where(feature: name, user_id: get_id(user)).any?
      Rollout.where(name: name).where('"user_id" = ? OR user_id IS NULL', get_id(user)).any? do |rollout|
        rollout.match?(user)
      end
    end
  end

  def self.all_active(user)
    return false unless user
    rollouts = []
    Rollout.where("user_id = ? or user_id is NULL", user.id).each do |rollout|
      unless OptOut.where(feature: rollout.name, user_id: user.id).any?
        rollouts << rollout.name if rollout.match?(user)
      end
    end
    rollouts.uniq.sort
  end

  private

  def self.get_id(user)
    [Fixnum, String].include?(user.class) ? user.to_i : user.id
  end

  def self.scanned_features
    @@scanned_features ||= Dir["app/views/**/*", 'app/controllers/**/*', 'app/helpers/**/*'].inject({}) do |obj, path|
      unless File.directory?(path)
        File.open(path) do |f|
          f.grep(/rollout\?/) do |line, no|
            line.scan(/rollout\?\s*\(*:(\w+)/).each do |line|
              obj[line[0]] ||= []
              obj[line[0]] << path
            end
          end
        end
      end

      obj
    end
  end
end

ActionController::Base.send :include, ArRollout::Controller::Helpers

class RolloutTask < Rails::Railtie
  rake_tasks do
    Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
  end
end
