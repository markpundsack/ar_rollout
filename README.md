# ArRollout

ArRollout is the ActiveRecord version of (Rollout)[https://github.com/jamesgolick/rollout], written
after the wonderful Railscast (315-rollout-and-degrade)[http://railscasts.com/episodes/315-rollout-and-degrade]
by Ryan Bates (thank you).
Originally released as https://github.com/doochoo-inc/ar_rollout but now maintained at https://github.com/markpundsack/ar_rollout.


This project rocks and uses MIT-LICENSE.

## HowTo

To use this gem, add on your gemfile

```ruby
gem 'ar_rollout'
```

and run the generator:

    rails generate ar_rollout

This will create for you the initializer and the migration.

The migration looks like this:

```ruby
class CreateRollout < ActiveRecord::Migration
  def up
    create_table :rollouts do |t|
      t.string :name
      t.string :group
      t.integer :user_id
      t.integer :percentage
      t.integer :failure_count
    end
  end

  def down
    drop_table :rollouts
  end
end
```

The initializer like this:

```ruby
ArRollout.configure do |configure|
  # # Here you can define the logic for your own groups
  # # For example, if you have a admin? method for your User class
  # # you can define an :admin group:

  configure.define_group(:all) do |user|
    true
  end

  # configure.define_group :admin do |user|
  #   user.admin?
  # end

  # What if you want to add your 3 developers using email to a :dev group?
  # configure.define_group :devs do |user|
  #   ["alice@yourcompany.com", "bob@yourcompany.com"].include? user.email
  # end
end
```

You have to run the migration to have the table rollouts created in database:

    rake db:migrate

And that's it. You're now ready to use ArRollout.

If you want to add a feature to a group you define in `config/initializer/ar_rollout.rb`, in your rails console
you can do:

```ruby
ArRollout.activate_group  :my_new_amazing_feature, :tester
ArRollout.activate_user   :my_new_amazing_feature, current_user
```

Or via rake with:

```
rake rollout:activate_group[my_new_amazing_feature,all]
```

So, in your controller/view you can use the helper method `rollout? :my_new_amazing_feature`, which will test if the
`current_user` is enabled to that feature.

In your *_controller.rb:

```ruby
before_filter :rollout
around_filter :degrade

private

def rollout
  redirect_to root_url, alert: "Feature unavailable" unless rollout? :phone
end

def degrade
  degrade_feature(:phone) { yield }
end
```

List known features with:

`ArRollout.features`

## Versions and ToDo

## ToDo

- Optimize user lookup
- Optimize database structure
- Merge ArRollout and Rollout class methods
- Autodetection of new features from code, before rollout begins

## Version 0.0.14 - 28 Nov 2012
- Add rake task 'rollout:list'

## Version 0.0.7 - 16 Aug 2012
- Add `ArRollout.info`

## Version 0.0.4 - 16 Aug 2012
- Add percentage support
- Add feature list with `ArRollout.features`

## Version 0.0.3 - 16 Aug 2012
- Add `ArRollout.deactivate_all` method and rake task

## Version 0.0.2 - 16 Aug 2012
- Add `:all` to default initializer

## Version 0.0.1 - 13 Jan 2012
- Generator which create both migration and initializer
- `activate_group` and `deactivate_group` methods are available
- `activate_user_` and `deactivate_user` methods are available

