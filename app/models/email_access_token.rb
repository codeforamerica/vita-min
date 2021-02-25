# == Schema Information
#
# Table name: email_access_tokens
#
#  id            :bigint           not null, primary key
#  email_address :citext           not null
#  token         :string           not null
#
# Indexes
#
#  index_email_access_tokens_on_token  (token)
#
class EmailAccessToken < ApplicationRecord
  validates_presence_of :token
  validates :email_address, presence: true, 'valid_email_2/email': true

  scope :by_raw_token, ->(raw_token) do
    where(token: Devise.token_generator.digest(EmailAccessToken, :token, raw_token))
  end
end
