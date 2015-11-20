class IncreaseCallbackUrlSize < ActiveRecord::Migration
  def change
    change_column :oauth_tokens, :callback_url, :string, :limit => 2000
  end
end
