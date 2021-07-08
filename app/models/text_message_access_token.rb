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

  before_create :ensure_token_limit
  after_create :increment_datadog

  def self.generate!(sms_phone_number:, client_id: nil)
    raw_verification_code, hashed_verification_code = VerificationCodeService.generate(sms_phone_number)
    [raw_verification_code, create!(
      sms_phone_number: sms_phone_number,
      token_type: "verification_code",
      token: Devise.token_generator.digest(self.class, :token, hashed_verification_code),
      client_id: client_id
    )]
  end

  def increment_datadog
    DatadogApi.increment("client_logins.verification_codes.text_message.created")
  end

  def ensure_token_limit
    existing_token_count = self.class.where(sms_phone_number: sms_phone_number).count
    if existing_token_count > 4
      self.class.where(sms_phone_number: sms_phone_number).order(created_at: :asc).limit(existing_token_count - 4).delete_all
    end
  end

  scope :lookup, ->(raw_token) do
    where(token: Devise.token_generator.digest(TextMessageAccessToken, :token, raw_token)).where("created_at > ?", Time.current - 2.days)
  end
end
