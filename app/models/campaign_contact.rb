# == Schema Information
#
# Table name: campaign_contacts
#
#  id                        :bigint           not null, primary key
#  email_address             :citext
#  email_notification_opt_in :boolean          default(FALSE)
#  first_name                :string
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
  validates :email_address, 'valid_email_2/email': true

  # def send email
  # def send sms
end
