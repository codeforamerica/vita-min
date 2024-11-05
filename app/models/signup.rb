# == Schema Information
#
# Table name: signups
#
#  id                               :bigint           not null, primary key
#  ctc_2022_open_message_sent_at    :datetime
#  email_address                    :citext
#  name                             :string
#  phone_number                     :string
#  puerto_rico_open_message_sent_at :datetime
#  zip_code                         :string
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#
class Signup < ApplicationRecord
  self.ignored_columns = [:sent_followup]
  validates_presence_of :name
  validate :phone_number_or_email_address
  validates :zip_code, zip_code: true, allow_blank: true
  validates :phone_number, e164_phone: true, allow_blank: true
  validates :email_address, 'valid_email_2/email': true

  def self.send_message(message_name, batch_size=nil, after: nil)
    message_class = "AutomatedMessage::#{message_name.camelize}".constantize
    message = message_class.new
    sent_at_column = "#{message_name}_sent_at"

    signups = Signup.where("#{message_name}_sent_at" => nil)
    signups = Signup.where('created_at >= ?', after) if after.present?
    signups.find_each do |signup|
      if signup.email_address.present? && signup.valid?
        SignupFollowupMailer.followup(email_address: signup.email_address, message: message).deliver
        signup.touch(sent_at_column)
      end

      if signup.phone_number.present?
        TwilioService.new(:ctc).send_text_message(to: signup.phone_number, body: message.sms_body)
        signup.touch(sent_at_column)
      end
    end
  end

  private

  def phone_number_or_email_address
    if phone_number.blank? && email_address.blank?
      errors.add(:email_address, I18n.t("forms.errors.need_one_communication_method"))
    end
  end
end
