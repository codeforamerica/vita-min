# == Schema Information
#
# Table name: state_file_archived_intakes
#
#  id                    :bigint           not null, primary key
#  email_address         :string
#  hashed_ssn            :string
#  mailing_apartment     :string
#  mailing_city          :string
#  mailing_state         :string
#  mailing_street        :string
#  mailing_zip           :string
#  permanently_locked_at :datetime
#  state_code            :string
#  tax_year              :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class StateFileArchivedIntake < ApplicationRecord
  has_one_attached :submission_pdf
  devise :lockable, unlock_in: 60.minutes, unlock_strategy: :time
  has_many :state_file_archived_intake_access_logs, class_name: 'StateFileArchivedIntakeAccessLog'
  has_many :state_file_archived_intake_requests, class_name: 'StateFileArchivedIntakeRequest'

  def full_address
    address_parts = [mailing_street, mailing_apartment, mailing_city, mailing_state, mailing_zip]
    address_parts.compact_blank.join(', ')
  end
end
