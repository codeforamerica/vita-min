# == Schema Information
#
# Table name: text_message_access_tokens
#
#  id               :bigint           not null, primary key
#  sms_phone_number :string           not null
#  token            :string           not null
#  token_type       :string           default("link")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  client_id        :bigint
#
# Indexes
#
#  index_text_message_access_tokens_on_client_id  (client_id)
#  index_text_message_access_tokens_on_token      (token)
#
class TextMessageAccessToken < ApplicationRecord
  validates_presence_of :token
  validates :token_type, inclusion: %w(link verification_code)
  validates :sms_phone_number, e164_phone: true

  scope :lookup, ->(raw_token) do
    where(token: Devise.token_generator.digest(TextMessageAccessToken, :token, raw_token)).where("created_at > ?", Time.current - 2.days)
  end
end
