require "rails_helper"

RSpec.describe "CampaignContacts backfill jobs" do
  before do
    allow(UpsertSourceIntoCampaignContacts).to receive(:call)
  end
  let(:start_date) { 1.year.ago }
  let(:end_date) { Time.current }

  describe CampaignContacts::BackfillGyrIntakesJob do
    subject(:job) { described_class.new }
    let!(:gyr_intake) do
      create :intake,
             primary_first_name: "Joe",
             primary_last_name: "Smith",
             email_address: "joe@example.com",
             sms_phone_number: "+15551234567",
             email_notification_opt_in: "yes",
             sms_notification_opt_in: "no",
             email_address_verified_at: Time.current,
             sms_phone_number_verified_at: Time.current,
             created_at: 1.day.ago,
             locale: "en"
    end

    it "iterates over eligible GYR intakes in the id range and calls the upsert service" do
      expect(UpsertSourceIntoCampaignContacts).to receive(:call).with(
        hash_including(
          source: :gyr,
          source_id: gyr_intake.id,
          first_name: "Joe",
          last_name: "Smith",
          email: "joe@example.com",
          phone: "+15551234567",
          email_opt_in: true,
          sms_opt_in: false,
          locale: "en"
        )
      )

      job.perform(1, 10, start_date, end_date)
    end

    it "uses PRIORITY_LOW" do
      expect(job.priority).to eq(ApplicationJob::PRIORITY_LOW)
    end
  end

  describe CampaignContacts::BackfillSignupsJob do
    subject(:job) { described_class.new }

    context "when there are signups" do
      let!(:signup) {
        create :signup,
               name: "Chris",
               email_address: "chris@example.com",
               phone_number: "+15550001111",
               created_at: 1.day.ago
      }

      it "iterates over signups in the id range and calls the upsert service" do
        expect(UpsertSourceIntoCampaignContacts).to receive(:call).with(
          hash_including(
            source: :signup,
            source_id: signup.id,
            first_name: "Chris",
            email: "chris@example.com",
            phone: "+15550001111",
            email_opt_in: true,
            sms_opt_in: true
          )
        )

        job.perform(signup.id, 20, start_date, end_date)
      end
    end

    context "when contact info is missing" do
      let!(:signup_no_phone) {
        create :signup,
               name: "bella",
               email_address: "bella@example.com",
               phone_number: nil,
               created_at: 1.day.ago
      }
      it "sets opt-ins for that method to false" do
        expect(UpsertSourceIntoCampaignContacts).to receive(:call).with(
          hash_including(
            source: :signup,
            source_id: signup_no_phone.id,
            first_name: "bella",
            email: "bella@example.com",
            phone: nil,
            email_opt_in: true,
            sms_opt_in: false
          )
        )

        job.perform(1, 20, start_date, end_date)
      end
    end

    it "uses PRIORITY_LOW" do
      expect(job.priority).to eq(ApplicationJob::PRIORITY_LOW)
    end
  end

  describe CampaignContacts::BackfillStateFileIntakesJob do
    let!(:state_intake) do
      create :state_file_az_intake,
             primary_first_name: "Sarah",
             primary_last_name: "Lee",
             email_address: "sarah@example.com",
             email_address_verified_at: Time.current,
             phone_number: "+15557654321",
             phone_number_verified_at: Time.current,
             email_notification_opt_in: "yes",
             sms_notification_opt_in: "yes",
             locale: "es",
             created_at: 1.day.ago
    end

    it "grab intakes between id range and upserts state file intake information" do
      allow(state_intake).to receive(:tax_return_year).and_return(2024)

      expect(UpsertSourceIntoCampaignContacts).to receive(:call).with(
        hash_including(
          source: :state_file,
          source_id: state_intake.id,
          first_name: "Sarah",
          last_name: "Lee",
          email: "sarah@example.com",
          phone: "+15557654321",
          email_opt_in: true,
          sms_opt_in: true,
          locale: "es",
          state_file_ref: hash_including(
            id: state_intake.id,
            type: "StateFileAzIntake",
            state: "az",
            tax_year: 2024
          )
        )
      )

      CampaignContacts::BackfillStateFileIntakesJob.perform_now("StateFileAzIntake", 1, 20, start_date, end_date)
    end

    it "uses PRIORITY_LOW" do
      expect(CampaignContacts::BackfillStateFileIntakesJob.new.priority).to eq(ApplicationJob::PRIORITY_LOW)
    end
  end
end
