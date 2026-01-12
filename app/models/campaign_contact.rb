# == Schema Information
#
# Table name: campaign_contacts
#
#  id                        :bigint           not null, primary key
#  email_address             :citext
#  email_notification_opt_in :boolean          default(FALSE)
#  first_name                :string           not null
#  gyr_2025_preseason_email  :datetime
#  gyr_2025_preseason_sms    :datetime
#  gyr_intake_ids            :bigint           default([]), is an Array
#  last_name                 :string
#  locale                    :string
#  sign_up_ids               :bigint           default([]), is an Array
#  sms_notification_opt_in   :boolean          default(FALSE)
#  sms_phone_number          :string
#  state_file_intake_refs    :jsonb            not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_campaign_contacts_on_email_address              (email_address) UNIQUE WHERE (email_address IS NOT NULL)
#  index_campaign_contacts_on_email_notification_opt_in  (email_notification_opt_in)
#  index_campaign_contacts_on_first_name_and_last_name   (first_name,last_name)
#  index_campaign_contacts_on_gyr_intake_ids             (gyr_intake_ids) USING gin
#  index_campaign_contacts_on_sign_up_ids                (sign_up_ids) USING gin
#  index_campaign_contacts_on_sms_notification_opt_in    (sms_notification_opt_in)
#  index_campaign_contacts_on_sms_phone_number           (sms_phone_number)
#  index_campaign_contacts_on_state_file_intake_refs     (state_file_intake_refs) USING gin
#
class CampaignContact < ApplicationRecord
  validates :sms_phone_number, e164_phone: true, allow_blank: true
  validates :email_address, 'valid_email_2/email': true, allow_blank: true

  def self.send_emails(message_name, sent_at_column, batch_size: 100)
    message = "AutomatedMessage::#{message_name.camelize}".constantize.new
    now = Time.current

    email_contacts_for(sent_at_column).find_each(batch_size: batch_size) do |contact|
      email = contact.email_address.to_s.strip
      next if contact.email.blank?

      updated = CampaignContact.where(id: contact.id, sent_at_column => nil)
                               .update_all(sent_at_column => now, updated_at: now)
      # skip if no matches and claim to prevent dupe
      next unless updated == 1

      CampaignMailer.followup(
        email_address: email,
        message: message,
        locale: contact.locale.presence || "en"
      ).deliver_later
    end
  end

  def self.email_contacts_for(sent_at_column)
    where(sent_at_column => nil, email_notification_opt_in: true)
      .where.not(email_address: nil)
  end

  def self.sms_contacts_for(sent_at_column)
    where(sent_at_column => nil, sms_notification_opt_in: true)
      .where.not(sms_phone_number: nil)
  end

  def self.sms_unique_phone_count(sent_at_column)
    sms_contacts_for(sent_at_column).distinct.count(:sms_phone_number)
  end
end
