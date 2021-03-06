require 'rails/generators'
require 'rails/generators/active_record'

class ArRolloutGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  extend ActiveRecord::Generators::Migration

  source_root File.expand_path("../templates", __FILE__)

  desc "This generator creates the initializer file at config/initializers"
  def copy_initializer_file
    copy_file "ar_rollout.rb", "config/initializers/ar_rollout.rb"
    migration_template "migration.rb", "db/migrate/create_rollout"
    migration_template "groups_migration.rb", "db/migrate/create_groups_and_groups_users"
    migration_template "opt_outs_migration.rb", "db/migrate/create_opt_outs"
  end
end


