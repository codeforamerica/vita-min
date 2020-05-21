# == Schema Information
#
# Table name: diy_intakes
#
#  id                 :bigint           not null, primary key
#  preferred_name     :string
#  state_of_residence :string
#  token              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
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
end
