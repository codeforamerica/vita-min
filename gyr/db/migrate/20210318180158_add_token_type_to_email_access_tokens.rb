class AddTokenTypeToEmailAccessTokens < ActiveRecord::Migration[6.0]
  def change
    add_column :email_access_tokens, :token_type, :string, default: "link"
  end
end
