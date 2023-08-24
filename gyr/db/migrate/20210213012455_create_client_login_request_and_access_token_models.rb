class CreateClientLoginRequestAndAccessTokenModels < ActiveRecord::Migration[6.0]
  def change
    create_table :text_message_access_tokens do |t|
      t.string :sms_phone_number, null: false
      t.string :token, null: false
    end
    add_index :text_message_access_tokens, :token

    create_table :email_access_tokens do |t|
      t.citext :email_address, null: false
      t.string :token, null: false
    end
    add_index :email_access_tokens, :token

    create_table :email_login_requests do |t|
      t.string :visitor_id, null: false
      t.references :email_access_token, null: false
      t.string :mailgun_id
      t.string :mailgun_status
    end
    add_index :email_login_requests, :mailgun_id
    add_index :email_login_requests, :visitor_id

    create_table :text_message_login_requests do |t|
      t.string :visitor_id, null: false
      t.references :text_message_access_token, null: false, index: { name: :text_message_login_request_access_token_id }
      t.string :twilio_sid
      t.string :twilio_status
    end
    add_index :text_message_login_requests, :twilio_sid
    add_index :text_message_login_requests, :visitor_id
  end
end
