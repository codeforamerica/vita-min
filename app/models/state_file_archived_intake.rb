# == Schema Information
#
# Table name: state_file_archived_intakes
#
#  id                :bigint           not null, primary key
#  email_address     :string
#  hashed_ssn        :string
#  mailing_apartment :string
#  mailing_city      :string
#  mailing_state     :string
#  mailing_street    :string
#  mailing_zip       :string
#  state_code        :string
#  tax_year          :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class StateFileArchivedIntake < ApplicationRecord
  has_one_attached :submission_pdf
  has_many :intake_requests, class_name: 'StateFileArchivedIntakeRequest'

  def self.full_address(mailing_street, mailing_apartment, mailing_city, mailing_state, mailing_zip)
    address_parts = [mailing_street, mailing_apartment, mailing_city, mailing_state, mailing_zip]
    address_parts.compact_blank.join(', ')
  end
end
