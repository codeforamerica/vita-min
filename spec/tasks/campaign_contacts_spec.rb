require "rails_helper"
require "rake"

RSpec.describe "campaign_contacts:backfill" do
  subject(:task) { Rake::Task["campaign_contacts:backfill"] }

  before(:all) do
    Rake.application.rake_require("tasks/campaign_contacts")
    Rake::Task.define_task(:environment)
  end

  before do
    task.reenable
  end

  describe "#upsert_campaign_contact!" do
    it "creates a new CampaignContact with correct fields" do
      expect do
        upsert_campaign_contact!(
          source: :gyr,
          source_id: 123,
          first_name: "Joe",
          last_name: "Smith",
          email: "joe@example.com",
          phone: "+15551234567",
          email_opt_in: true,
          sms_opt_in: true,
          locale: "en"
        )
      end.to change(CampaignContact, :count).by(1)

      contact = CampaignContact.last
      expect(contact.email_address).to eq("joe@example.com")
      expect(contact.sms_phone_number).to eq("+15551234567")
      expect(contact.first_name).to eq("Joe")
      expect(contact.last_name).to eq("Smith")
      expect(contact.email_notification_opt_in).to eq(true)
      expect(contact.sms_notification_opt_in).to eq(true)
      expect(contact.locale).to eq("en")
      expect(contact.gyr_intake_ids).to include(123)
    end

    it "reuses an existing contact by email if email is present" do
      existing = create(
        :campaign_contact,
        email_address: "joe@example.com",
        sms_phone_number: nil,
        first_name: "Old",
        email_notification_opt_in: false,
        sms_notification_opt_in: false,
        gyr_intake_ids: []
      )

      expect do
        upsert_campaign_contact!(
          source: :gyr,
          source_id: 77,
          first_name: "Joe",
          last_name: "Smith",
          email: "joe@example.com",
          phone: "+15551234567",
          email_opt_in: true,
          sms_opt_in: true,
          locale: "en"
        )
      end.not_to change(CampaignContact, :count)

      existing.reload
      expect(existing.email_address).to eq("joe@example.com")
      expect(existing.sms_phone_number).to eq("+15551234567")
      expect(existing.first_name).to eq("Joe")
      expect(existing.email_notification_opt_in).to eq(true)
      expect(existing.sms_notification_opt_in).to eq(true)
      expect(existing.gyr_intake_ids).to match_array([77])
    end

    it "creates new contact for new email, if unique email present and email opt in true, even if campaign contact with same phone number exists" do
      create(:campaign_contact, sms_phone_number: "+15551234567", email_address: "joanna@example.com")

      expect do
        upsert_campaign_contact!(
          source: :signup,
          source_id: 1,
          first_name: "Sarah",
          email: "sarah@example.com",
          phone: "+15551234567",
          email_opt_in: true,
          sms_opt_in: true
        )
      end.to change(CampaignContact, :count).by(1)

      expect(CampaignContact.where(sms_phone_number: "+15551234567").count).to eq(2)
    end

    it "uses same contact with same phone number only when email is blank and email_opt_in is false" do
      existing = create(
        :campaign_contact,
        sms_phone_number: "+15551234567",
        email_address: nil,
        first_name: "Household",
        sms_notification_opt_in: false
      )

      expect do
        upsert_campaign_contact!(
          source: :state_file,
          source_id: 9,
          first_name: "Joe",
          last_name: "Smith",
          email: nil,
          phone: "+15551234567",
          email_opt_in: false,
          sms_opt_in: true
        )
      end.not_to change(CampaignContact, :count)

      existing.reload
      expect(existing.sms_notification_opt_in).to eq(true)
    end

    it "opt-ins remain true even if later sources are false" do
      contact = create(
        :campaign_contact,
        email_address: "joe@example.com",
        sms_phone_number: "+15551234567",
        email_notification_opt_in: true,
        sms_notification_opt_in: true
      )

      upsert_campaign_contact!(
        source: :gyr,
        source_id: 1,
        first_name: "Joe",
        last_name: "Smith",
        email: "joe@example.com",
        phone: "+15551234567",
        email_opt_in: false,
        sms_opt_in: false
      )

      contact.reload
      expect(contact.email_notification_opt_in).to eq(true)
      expect(contact.sms_notification_opt_in).to eq(true)
    end

    it "appends state_file_ref and does not duplicate the same based on id & type)" do
      upsert_campaign_contact!(
        source: :state_file,
        source_id: 10,
        first_name: "Joe",
        last_name: "Smith",
        email: "joe@example.com",
        phone: "+15551234567",
        email_opt_in: true,
        sms_opt_in: true,
        state_file_ref: {
          id: 10,
          type: "StateFile::AzIntake",
          state: "AZ",
          tax_year: 2024
        }
      )

      contact = CampaignContact.find_by(email_address: "joe@example.com")
      expect(contact.state_file_intake_refs.length).to eq(1)

      upsert_campaign_contact!(
        source: :state_file,
        source_id: 10,
        first_name: "Joe",
        last_name: "Smith",
        email: "joe@example.com",
        phone: "+15551234567",
        email_opt_in: true,
        sms_opt_in: true,
        state_file_ref: {
          id: 10,
          type: "StateFile::AzIntake",
          state: "AZ",
          tax_year: 2024
        }
      )

      contact.reload
      expect(contact.state_file_intake_refs.length).to eq(1)
    end

    it "tracks gyr_intake_ids and sign_up_ids without duplicates" do
      upsert_campaign_contact!(
        source: :gyr,
        source_id: 1,
        first_name: "Joe",
        last_name: "Smith",
        email: "joe@example.com",
        phone: nil,
        email_opt_in: true,
        sms_opt_in: false
      )

      upsert_campaign_contact!(
        source: :gyr,
        source_id: 1,
        first_name: "Joe",
        last_name: "Smith",
        email: "joe@example.com",
        phone: nil,
        email_opt_in: true,
        sms_opt_in: false
      )

      upsert_campaign_contact!(
        source: :signup,
        source_id: 55,
        first_name: "Joe",
        email: "joe@example.com",
        phone: nil,
        email_opt_in: true,
        sms_opt_in: false
      )

      contact = CampaignContact.find_by(email_address: "joe@example.com")
      expect(contact.gyr_intake_ids).to eq([1])
      expect(contact.sign_up_ids).to eq([55])
    end
  end

  describe "#choose_name" do
    it "prefers incoming for nonsignup sources" do
      expect(choose_name("Old", "New", source: :gyr)).to eq("New")
      expect(choose_name("Old", "New", source: :state_file)).to eq("New")
    end

    it "prefers intake names over name from signup source" do
      expect(choose_name("IntakeName", "SignupName", source: :signup)).to eq("IntakeName")
    end
  end
end
