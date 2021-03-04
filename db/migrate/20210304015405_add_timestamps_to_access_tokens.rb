class AddTimestampsToAccessTokens < ActiveRecord::Migration[6.0]
  def change
    add_timestamps :email_access_tokens, default: Time.now
    add_timestamps :text_message_access_tokens, default: Time.now
    change_column_default :text_message_access_tokens, :created_at, to: nil, from: Time.now
    change_column_default :text_message_access_tokens, :updated_at, to: nil, from: Time.now
    change_column_default :email_access_tokens, :created_at, to: nil, from: Time.now
    change_column_default :email_access_tokens, :updated_at, to: nil, from: Time.now
  end
end
