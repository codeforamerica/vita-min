class AddLoginRequestFieldsToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :login_token, :string, null: true
    add_column :clients, :login_requested_at, :datetime, null: true
  end
end
