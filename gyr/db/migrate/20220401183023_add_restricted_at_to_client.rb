class AddRestrictedAtToClient < ActiveRecord::Migration[6.1]
  def change
    add_column :clients, :restricted_at, :datetime
  end
end
