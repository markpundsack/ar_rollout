namespace :rollout do
	desc "Activate a feature for a specific user"
	task :activate_user, [:feature, :user_id] => :environment do |t, args|
		ArRollout.activate_user(args.feature,args.user_id)
	end

	desc "Deactivate a feature for a specific user"
	task :deactivate_user, [:feature, :user_id] => :environment do |t, args|
		ArRollout.deactivate_user(args.feature,args.user_id)
	end

	desc "Activate a feature for a group"
	task :activate_group, [:feature, :user_id] => :environment do |t, args|
		ArRollout.activate_group(args.feature,args.user_id)
	end

	desc "Deactivate a feature for a group"
	task :deactivate_group, [:feature, :user_id] => :environment do |t, args|
		ArRollout.deactivate_group(args.feature,args.user_id)
	end

	desc "Activate a feature for a percentage"
	task :activate_percentage, [:feature, :percentage] => :environment do |t, args|
		ArRollout.activate_percentage(args.feature,args.percentage)
	end

	desc "Deactivate a feature"
	task :deactivate_all, [:feature] => :environment do |t, args|
		ArRollout.deactivate_all(args.feature)
	end

  desc "List all features"
  task :list, [] => :environment do |t, args|
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
