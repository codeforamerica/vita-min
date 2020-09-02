# == Schema Information
#
# Table name: case_files
#
#  id               :bigint           not null, primary key
#  email_address    :string           not null
#  phone_number     :string           not null
#  preferred_name   :string           not null
#  sms_phone_number :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class CaseFile < ApplicationRecord
  def self.create_from_intake(intake)
    create(
      preferred_name: intake.preferred_name,
      email_address: intake.email_address,
      phone_number: intake.phone_number,
      sms_phone_number: intake.sms_phone_number,
    )
  end
end
