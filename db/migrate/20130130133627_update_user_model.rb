class UpdateUserModel < ActiveRecord::Migration
  def up
    change_table :users do |t|
          t.binary :groups
          t.string :firstname
          t.string :lastname
    end
    
    remove_column :users, :is_super_user
    remove_column :users, :department
  end

  def down
    change_table :users do |t|
          t.boolean :is_super_user
          t.string :department
    end    
    remove_column :users, :groups
    remove_column :users, :firstname
    remove_column :users, :lastname    
    
  end
end
