class AddOauthInfoToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :external_provider, :string
    add_column :users, :external_uid, :string
  end
end
