# == Schema Information
#
# Table name: ctc_signups
#
#  id                          :bigint           not null, primary key
#  beta_email_sent_at          :datetime
#  email_address               :string
#  launch_announcement_sent_at :datetime
#  name                        :string
#  phone_number                :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
class CtcSignup < ApplicationRecord
  validates_presence_of :name
  validate :phone_number_or_email_address
  validates :phone_number, e164_phone: true, allow_blank: true
  validates :email_address, 'valid_email_2/email': true

  private

  def phone_number_or_email_address
    if phone_number.blank? && email_address.blank?
      errors.add(:email_address, I18n.t("forms.errors.need_one_communication_method"))
    end
  end
end
