# == Schema Information
#
# Table name: state_file_archived_intakes
#
#  id                 :bigint           not null, primary key
#  email_address      :string
#  hashed_ssn         :string
#  mailing_apartment  :string
#  mailing_city       :string
#  mailing_state      :string
#  mailing_street     :string
#  mailing_zip        :string
#  state_code         :string
#  tax_year           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  original_intake_id :string
#
class StateFileArchivedIntake < ApplicationRecord
  has_one_attached :submission_pdf
  has_many :access_logs, class_name: 'StateFileArchivedIntakeAccessLog'
end
