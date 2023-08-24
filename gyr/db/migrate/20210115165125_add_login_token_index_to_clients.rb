class AddLoginTokenIndexToClients < ActiveRecord::Migration[6.0]
  def change
    add_index :clients, :login_token
  end
end
