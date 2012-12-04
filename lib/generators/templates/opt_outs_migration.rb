class CreateOptOuts < ActiveRecord::Migration
  def up
    create_table :opt_outs do |t|
      t.integer :user_id
      t.string :feature
      t.timestamps
    end

    add_index :opt_outs, [:user_id, :feature], unique: true
  end

  def down
    drop_table :opt_outs
  end
end
