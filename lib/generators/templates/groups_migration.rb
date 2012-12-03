class CreateGroupsAndGroupsUsers < ActiveRecord::Migration
  def up
    create_table :groups do |t|
      t.string :name
    end

    create_table :groups_users do |t|
      t.references :group
      t.references :user
    end

    add_index :groups_users, [:group_id, :user_id], unique: true
  end

  def down
    drop_table :groups
    drop_table :groups_users
  end
end
