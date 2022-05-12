# == Schema Information
#
# Table name: signups
#
#  id            :bigint           not null, primary key
#  email_address :citext
#  name          :string
#  phone_number  :string
#  sent_followup :boolean          default(FALSE)
#  zip_code      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Signup < ApplicationRecord
  self.ignored_columns = [:sent_followup]
  validates_presence_of :name
  validate :phone_number_or_email_address
  validates :zip_code, zip_code: true, allow_blank: true
  validates :phone_number, e164_phone: true, allow_blank: true
  validates :email_address, 'valid_email_2/email': true

  private

  def phone_number_or_email_address
    if phone_number.blank? && email_address.blank?
      errors.add(:email_address, I18n.t("forms.errors.need_one_communication_method"))
    end
  end
end
