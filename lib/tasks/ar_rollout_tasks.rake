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
end