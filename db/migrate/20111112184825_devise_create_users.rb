class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|

      t.string :login
      t.string :name
      t.string :email
      t.string :department
      t.boolean :is_super_user, :default => false
      t.integer :role_id
      
      t.timestamps
    end

    add_index :users, :login,                :unique => true

  end

  def self.down
    drop_table :users
  end
end
