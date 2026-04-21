# == Schema Information
#
# Table name: campaign_contacts
#
#  id                        :bigint           not null, primary key
#  diy_intake_ids            :integer          default([]), is an Array
#  email_address             :citext
#  email_notification_opt_in :boolean          default(FALSE)
#  first_name                :string
#  gyr_intake_ids            :bigint           default([]), is an Array
#  last_name                 :string
#  latest_diy_intake_at      :datetime
#  latest_gyr_intake_at      :datetime
#  latest_signup_at          :datetime
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
#  index_campaign_contacts_on_gyr_suppression            (suppressed_for_gyr_product_year)
#  index_campaign_contacts_on_latest_gyr_intake_at       (latest_gyr_intake_at)
#  index_campaign_contacts_on_latest_signup_at           (latest_signup_at)
#  index_campaign_contacts_on_sign_up_ids                (sign_up_ids) USING gin
#  index_campaign_contacts_on_sms_notification_opt_in    (sms_notification_opt_in)
#  index_campaign_contacts_on_sms_phone_number           (sms_phone_number)
#  index_campaign_contacts_on_state_file_intake_refs     (state_file_intake_refs) USING gin
#
require "rails_helper"

RSpec.describe CampaignContact, type: :model do
  before do
    allow(Rails.configuration).to receive(:start_of_unique_links_only_intake).and_return(1.month.ago)
    allow_any_instance_of(MultiTenantService).to receive(:current_tax_year).and_return(2025)
    allow(Rails.configuration).to receive(:tax_year_filing_seasons).and_return({ 2024 => [1.year.ago, 2.weeks.ago] })
  end

  describe "validations" do
    it "validates email format" do
      contact = build(:campaign_contact, email_address: "bad_email")
      expect(contact).not_to be_valid
    end

    it "allows blank email" do
      contact = build(:campaign_contact, email_address: nil)
      expect(contact).to be_valid
    end

    it "validates sms phone format" do
      contact = build(:campaign_contact, sms_phone_number: "12345")
      expect(contact).not_to be_valid
    end
  end

  describe ".excluding_paused_email_domains" do
    let!(:paused_domain) { create(:paused_email_domain, domain: "yahoo.com", paused_until: 1.hour.from_now) }
    let!(:active_contact) { create(:campaign_contact, email_address: "user@gmail.com") }
    let!(:paused_contact) { create(:campaign_contact, email_address: "user@yahoo.com") }

    it "excludes contacts with paused domains" do
      result = described_class.excluding_paused_email_domains

      expect(result).to include(active_contact)
      expect(result).not_to include(paused_contact)
    end
  end

  describe ".eligible_for_email" do
    let(:message_name) { "season_start" }

    let!(:eligible_contact) do
      create(:campaign_contact,
             email_notification_opt_in: true,
             email_address: "ok@gmail.com",
             latest_gyr_intake_at: 2.months.ago
      )
    end

    let!(:already_emailed_contact) do
      contact = create(:campaign_contact,
                       email_notification_opt_in: true,
                       email_address: "sent@gmail.com"
      )
      create(:campaign_email, message_name: message_name, campaign_contact: contact)
      contact
    end

    let!(:opted_out_contact) do
      create(:campaign_contact,
             email_notification_opt_in: false,
             email_address: "nope@gmail.com"
      )
    end

    let!(:recent_intake_contact) do
      create(:campaign_contact,
             email_notification_opt_in: true,
             email_address: "intake@gmail.com",
             latest_gyr_intake_at: 1.day.ago
      )
    end

    it "returns only eligible contacts" do
      result = described_class.eligible_for_email(message_name)

      expect(result).to include(eligible_contact)
      expect(result).not_to include(already_emailed_contact)
      expect(result).not_to include(opted_out_contact)
      expect(result).not_to include(recent_intake_contact)
    end
  end

  describe ".eligible_for_email_with_recent_signup" do
    let(:message_name) { "season_start" }

    let!(:recent_signup_contact) do
      create(:campaign_contact,
             email_notification_opt_in: true,
             email_address: "recent@gmail.com",
             latest_signup_at: 1.day.ago
      )
    end

    let!(:old_signup_contact) do
      create(:campaign_contact,
             email_notification_opt_in: true,
             email_address: "old@gmail.com",
             latest_signup_at: 3.months.ago
      )
    end

    it "returns only contacts with recent signups" do
      result = described_class.eligible_for_email_with_recent_signup(message_name)

      expect(result).to include(recent_signup_contact)
      expect(result).not_to include(old_signup_contact)
    end
  end

  describe ".eligible_for_text_message" do
    let(:message_name) { "text_outreach" }

    let!(:eligible_contact) do
      create(:campaign_contact,
             sms_notification_opt_in: true,
             sms_phone_number: "+14155551234",
             latest_gyr_intake_at: 2.months.ago
      )
    end

    let!(:already_messaged_contact) do
      contact = create(:campaign_contact,
                       sms_notification_opt_in: true,
                       sms_phone_number: "+14155559876"
      )
      create(:campaign_sms, message_name: message_name, to_phone_number: contact.sms_phone_number)
      contact
    end

    let!(:opted_out_contact) do
      create(:campaign_contact,
             sms_notification_opt_in: false,
             sms_phone_number: "+14155550000"
      )
    end

    it "returns only eligible contacts" do
      result = described_class.eligible_for_text_message(message_name)

      expect(result).to include(eligible_contact)
      expect(result).not_to include(already_messaged_contact)
      expect(result).not_to include(opted_out_contact)
    end
  end

  describe ".eligible_for_text_message_with_recent_signup" do
    let(:message_name) { "text_outreach" }

    let!(:recent_signup_contact) do
      create(:campaign_contact,
             sms_notification_opt_in: true,
             sms_phone_number: "+14155551111",
             latest_signup_at: 1.day.ago
      )
    end

    let!(:old_signup_contact) do
      create(:campaign_contact,
             sms_notification_opt_in: true,
             sms_phone_number: "+14155552222",
             latest_signup_at: 3.months.ago
      )
    end

    it "returns only contacts with recent signups" do
      result = described_class.eligible_for_text_message_with_recent_signup(message_name)

      expect(result).to include(recent_signup_contact)
      expect(result).not_to include(old_signup_contact)
    end
  end
end