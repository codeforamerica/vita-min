class AddTimezoneToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :timezone, :string, default: "Eastern Time (US & Canada)"
  end
end
