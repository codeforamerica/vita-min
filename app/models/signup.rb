# == Schema Information
#
# Table name: signups
#
#  id            :bigint           not null, primary key
#  email_address :string
#  name          :string
#  phone_number  :string
#  zip_code      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Signup < ApplicationRecord
  validates_presence_of :name
  validate :phone_number_or_email_address

  private

  def phone_number_or_email_address
    if phone_number.blank? and email_address.blank?
      errors.add(:phone_number, I18n.t("forms.errors.need_one_communication_method"))
    end
  end
end
