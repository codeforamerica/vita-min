# == Schema Information
#
# Table name: campaign_contacts
#
#  id                        :bigint           not null, primary key
#  email_address             :citext
#  email_notification_opt_in :boolean          default(FALSE)
#  first_name                :string
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
FactoryBot.define do
  factory :campaign_contact do
    sequence(:email_address) { |n| "person#{n}@example.com" }
    sequence(:sms_phone_number) { |n| "+1555000#{n.to_s.rjust(4, "0")}" }

    first_name { "Test" }
    last_name  { "User" }
    locale     { "en" }
    email_notification_opt_in { false }
    sms_notification_opt_in   { false }
    gyr_intake_ids { [] }
    sign_up_ids    { [] }
    state_file_intake_refs { [] }

    trait :email_opted_in do
      email_notification_opt_in { true }
      email_address { "opted_in@example.com" }
    end

    trait :sms_opted_in do
      sms_notification_opt_in { true }
      sms_phone_number { "+15551234567" }
    end

    trait :with_gyr_intake_ids do
      gyr_intake_ids { [1, 2] }
    end

    trait :with_sign_up_ids do
      sign_up_ids { [10, 11] }
    end

    trait :with_state_file_ref do
      state_file_intake_refs do
        [
          {
            "id" => 123,
            "type" => "StateFile::AzIntake",
            "state" => "AZ",
            "tax_year" => 2024
          }
        ]
      end
    end
  end
end
