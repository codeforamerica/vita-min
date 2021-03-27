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
  validates :phone_number, e164_phone: true, allow_blank: true
  validates :email_address, 'valid_email_2/email': true


  def self.valid_emails_with_unsent_followups_count
    distinct(:email_address).where(sent_followup: false).pluck(:email_address).filter do |email|
      ValidEmail2::Address.new(email).valid?
    end.count
  end

  def self.with_unsent_followups
    distinct(:email_address).where(sent_followup: false)
  end


  def self.send_followup_emails(batch_size = nil)
    valid_count = 0
    with_unsent_followups.limit(batch_size).find_each do |signup|
      next unless ValidEmail2::Address.new(signup.email_address).valid?

      valid_count += 1
      SignupFollowupMailer.followup(signup.email_address, signup.name).deliver_later
      Signup.where(email_address: signup.email_address).update_all(sent_followup: true)
    end
    valid_count
  end

  private

  def phone_number_or_email_address
    if phone_number.blank? && email_address.blank?
      errors.add(:email_address, I18n.t("forms.errors.need_one_communication_method"))
    end
  end
end
