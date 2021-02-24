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
  validates_presence_of :name
  validate :phone_number_or_email_address
  validates :zip_code, zip_code: true, allow_blank: true
  validates :phone_number, phone: true, allow_blank: true, format: { with: /\A\+1[0-9]{10}\z/ }
  validates :email_address, 'valid_email_2/email': true


  def self.valid_emails_with_unsent_followups
    distinct(:email_address).where(sent_followup: false).filter do |signup|
      ValidEmail2::Address.new(signup.email_address).valid? && !signup.email_address.include?("@tinfoil-fake-site.com")
    end
  end

  def self.send_followup_emails(batch_size = nil)
    emails = batch_size ? valid_emails_with_unsent_followups.slice(0..(batch_size - 1)) : valid_emails_with_unsent_followups
    emails.each do |signup|
      SignupFollowupMailer.followup(signup.email_address, signup.name).deliver_later
      Signup.where(email_address: signup.email_address).update_all(sent_followup: true)
    end
  end

  private

  def phone_number_or_email_address
    if phone_number.blank? && email_address.blank?
      errors.add(:email_address, I18n.t("forms.errors.need_one_communication_method"))
    end
  end
end
