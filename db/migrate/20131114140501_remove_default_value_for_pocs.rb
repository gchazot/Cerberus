class RemoveDefaultValueForPocs < ActiveRecord::Migration
  def up
    change_column_default(:client_applications, :poc, nil)
  end

  def down
    change_column_default(:client_applications, :poc, "Not defined")
  end
end
