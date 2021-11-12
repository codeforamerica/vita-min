class IndexEmailAddressOnEmailAccessTokens < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :email_access_tokens, :email_address, algorithm: :concurrently
  end
end
