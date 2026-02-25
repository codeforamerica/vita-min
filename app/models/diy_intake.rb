# == Schema Information
#
# Table name: diy_intakes
#
#  id                      :bigint           not null, primary key
#  clicked_chat_with_us_at :datetime
#  email_address           :string
#  filing_frequency        :integer          default("unfilled"), not null
#  locale                  :string
#  preferred_first_name    :string
#  received_1099           :integer          default("unfilled"), not null
#  referrer                :string
#  source                  :string
#  token                   :string
#  zip_code                :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  visitor_id              :string
#
class DiyIntake < ApplicationRecord
  attr_accessor :email_address_confirmation

  enum received_1099: { unfilled: 0, yes: 1, no: 2 }, _prefix: :received_1099
  enum filing_frequency: { unfilled: 0, every_year: 1, some_years: 2, not_filed: 3 }, _prefix: :filing_frequency

  has_secure_token :token

  validates :email_address, presence: true, 'valid_email_2/email': { mx: true }, confirmation: true
  
  def self.should_carry_over_params_from?(intake)
    intake && intake.updated_at > 30.minutes.ago && intake.preferred_name.present? && intake.triage_filing_frequency.present?
  end
end
