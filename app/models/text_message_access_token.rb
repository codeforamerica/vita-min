# == Schema Information
#
# Table name: text_message_access_tokens
#
#  id               :bigint           not null, primary key
#  sms_phone_number :string           not null
#  token            :string           not null
#
# Indexes
#
#  index_text_message_access_tokens_on_token  (token)
#
class TextMessageAccessToken < ApplicationRecord
  validates_presence_of :token
  validates :sms_phone_number, phone: true, format: { with: /\A\+1[0-9]{10}\z/ }

  scope :by_raw_token, ->(raw_token) do
    where(token: Devise.token_generator.digest(TextMessageAccessToken, :token, raw_token))
  end
end
