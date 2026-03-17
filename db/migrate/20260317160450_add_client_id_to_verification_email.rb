class AddClientIdToVerificationEmail < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :email_login_requests, :client_id, :bigint
    add_index :email_login_requests, :client_id, algorithm: :concurrently
  end
end
