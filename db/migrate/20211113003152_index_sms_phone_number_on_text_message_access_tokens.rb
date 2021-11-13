class IndexSmsPhoneNumberOnTextMessageAccessTokens < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :text_message_access_tokens, :sms_phone_number, algorithm: :concurrently
  end
end
