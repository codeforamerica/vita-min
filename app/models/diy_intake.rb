# == Schema Information
#
# Table name: diy_intakes
#
#  id                 :bigint           not null, primary key
#  email_address      :string
#  preferred_name     :string
#  referrer           :string
#  source             :string
#  state_of_residence :string
#  token              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  requester_id       :bigint
#  ticket_id          :bigint
#  visitor_id         :string
#
# Indexes
#
#  index_diy_intakes_on_token  (token) UNIQUE
#
class DiyIntake < ApplicationRecord
  validates_presence_of(:preferred_name)
  validates_presence_of(:state_of_residence)
  validates_presence_of(:token)
  validates_uniqueness_of(:token)
  attr_readonly(:token)

  before_validation :issue_token

  ##
  # issues a clean token prior to validation, if the model hasn't persisted.
  # checks for duplicates.
  def issue_token
    return if persisted?

    while DiyIntake.find_by(token: new_token = SecureRandom.urlsafe_base64(10)).present?
      # nothing, just making sure this random number hasn't been used.
    end

    self.token = new_token
  end

  def start_filing_url
    Rails.application.routes.url_helpers.diy_start_filing_url(:token => token)
  end

  def duplicate_diy_intakes
    DiyIntake
      .where(email_address: email_address)
      .where.not(ticket_id: nil)
      .where.not(requester_id: nil)
  end
end
