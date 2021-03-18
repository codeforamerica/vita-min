class AddTokenTypeToTextMessageAccessTokens < ActiveRecord::Migration[6.0]
  def change
    add_column :text_message_access_tokens, :token_type, :string, default: "link"
  end
end
