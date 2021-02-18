# == Schema Information
#
# Table name: signups
#
#  id            :bigint           not null, primary key
#  email_address :citext
#  name          :string
#  phone_number  :string
#  zip_code      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Signup < ApplicationRecord
  validates_presence_of :name
  validate :phone_number_or_email_address
  validates :zip_code, zip_code: true, allow_blank: true
  validates :phone_number, phone: true, allow_blank: true, format: { with: /\A\+1[0-9]{10}\z/ }
  validates :email_address, 'valid_email_2/email': true

  def self.valid_emails
    distinct(:email_address).pluck(:email_address).filter do |email|
      ValidEmail2::Address.new(email).valid?
    end
  end

  def self.send_followup_emails
    valid_emails.each do |email|
      SignupFollowupMailer.followup(email).deliver_later
    end
  end

  private

  def phone_number_or_email_address
    if phone_number.blank? && email_address.blank?
      errors.add(:email_address, I18n.t("forms.errors.need_one_communication_method"))
    end
  end
end
