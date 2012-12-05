namespace :rollout do
  desc "Activate a feature for a specific user"
  task :activate_user, [:feature, :user_id] => :environment do |t, args|
    ArRollout.activate_user(args.feature,args.user_id)
  end

  desc "Deactivate a feature for a specific user"
  task :deactivate_user, [:feature, :user_id] => :environment do |t, args|
    ArRollout.deactivate_user(args.feature,args.user_id)
  end

  desc "Exclude a user from a feature"
  task :exclude_user, [:feature, :user_id] => :environment do |t, args|
    ArRollout.omit_user(args.feature, args.user_id)
  end

  desc "Permit a user to have a feature rolled out to it"
  task :permit_user, [:feature, :user_id] => :environment do |t, args|
    ArRollout.permit_user(args.feature, args.user_id)
  end

  desc "Activate a feature for a group"
  task :activate_group, [:feature, :group] => :environment do |t, args|
    ArRollout.activate_group(args.feature,args.group)
  end

  desc "Deactivate a feature for a group"
  task :deactivate_group, [:feature, :group] => :environment do |t, args|
    ArRollout.deactivate_group(args.feature,args.group)
  end

  desc "Activate a feature for a percentage"
  task :activate_percentage, [:feature, :percentage] => :environment do |t, args|
    ArRollout.activate_percentage(args.feature,args.percentage)
  end

  desc "Deactivate percentage rollout for a feature"
  task :deactivate_percentage, [:feature] => :environment do |t, args|
    ArRollout.deactivate_percentage(args.feature)
  end

  desc "Deactivate a feature"
  task :deactivate, [:feature] => :environment do |t, args|
    ArRollout.deactivate(args.feature)
  end

  desc "List groups"
  task :groups, [] => :environment do |t, args|
    puts ArRollout.groups
  end

  desc "List active groups"
  task :active_groups, [] => :environment do |t, args|
    puts ArRollout.active_groups
  end

  desc "Create a group"
  task :create_group, [:group] => :environment do |t, args|
    ArRollout.create_group(args.group)
  end

  desc "Change a group's name"
  task :change_group_name, [:old_name, :new_name] => :environment do |t, args|
    ArRollout.change_group_name(args.old_name, args.new_name)
  end

  desc "Add a user to a group"
  task :add_user_to_group, [:group, :user_id] => :environment do |t, args|
    ArRollout.add_user_to_group(args.group, args.user_id)
  end

  desc "Remove a user from a group"
  task :remove_user_from_group, [:group, :user_id] => :environment do |t, args|
    ArRollout.remove_user_from_group(args.group, args.user_id)
  end

  desc "Delete a group"
  task :delete_group, [:group] => :environment do |t, args|
    ArRollout.delete_group(args.group)
  end

  desc "List features"
  task :features, [] => :environment do |t, args|
    puts ArRollout.features
  end

  desc "Display a summary of features"
  task :summary, [] => :environment do |t, args|
    puts(Rollout.all.group_by(&:name).to_a.inject('') do |output, feature|
      feature_name = feature[0]
      rollouts = feature[1]

      output << "\n"
      output << "#{feature[0]}\n"
      output << "  \033[31mGroups:\033[0m"
      output << "            #{rollouts.select(&:group).collect(&:group).join(', ')}\n"
      output << "  \033[31mUser ID count:\033[0m"
      output << "     #{rollouts.select(&:user_id).count}\n"
      output << "  \033[31mPercentage:\033[0m"
      output << "        #{rollouts.select(&:percentage).collect(&:percentage).join(', ')}\n"
    end)
  end
end
