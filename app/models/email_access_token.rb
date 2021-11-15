# == Schema Information
#
# Table name: email_access_tokens
#
#  id            :bigint           not null, primary key
#  email_address :citext           not null
#  token         :string           not null
#  token_type    :string           default("link")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  client_id     :bigint
#
# Indexes
#
#  index_email_access_tokens_on_client_id      (client_id)
#  index_email_access_tokens_on_email_address  (email_address)
#  index_email_access_tokens_on_token          (token)
#
class EmailAccessToken < ApplicationRecord
  validates_presence_of :token
  validates_presence_of :email_address
  validates :token_type, inclusion: %w(link verification_code)
  validate :one_or_more_valid_email_addresses
  after_create :increment_datadog
  before_create :ensure_token_limit

  scope :lookup, ->(raw_token) do
    where(token: Devise.token_generator.digest(EmailAccessToken, :token, raw_token)).where("created_at > ?", Time.current - 2.days)
  end

  def self.generate!(email_address:, client_id: nil)
    raw_verification_code, hashed_verification_code = VerificationCodeService.generate(email_address)
    [raw_verification_code, create!(
        email_address: email_address,
        token_type: "verification_code",
        token: Devise.token_generator.digest(self.class, :token, hashed_verification_code),
        client_id: client_id
    )]
  end

  private

  def increment_datadog
    DatadogApi.increment("client_logins.verification_codes.email.created")
  end

  def ensure_token_limit
    existing_token_count = self.class.where(email_address: email_address).count

    if existing_token_count > 4
      self.class.where(email_address: email_address).order(created_at: :asc).limit(existing_token_count - 4).delete_all
    end
  end

  def one_or_more_valid_email_addresses
    unless email_address.present? && email_address.split(",").map { |email| ValidEmail2::Address.new(email).valid? }.all?
      errors.add(:email_address, :invalid)
    end
  end
end
