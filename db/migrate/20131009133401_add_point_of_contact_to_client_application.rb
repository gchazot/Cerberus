class AddPointOfContactToClientApplication < ActiveRecord::Migration
  def change
    add_column :client_applications, :poc, :string, default: "Not defined", null: false
  end
end
