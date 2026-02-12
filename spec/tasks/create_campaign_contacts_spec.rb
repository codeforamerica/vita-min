require "rails_helper"
require "rake"

RSpec.describe "create_campaign_contacts:backfill" do
  before(:all) do
    Rake.application.rake_require("tasks/create_campaign_contacts", [Rails.root.join("lib").to_s])
    Rake::Task.define_task(:environment)
  end

  let(:task) { Rake::Task["create_campaign_contacts:backfill"] }

  let(:window_start) { Date.parse("2025-11-01").beginning_of_day }
  let(:window_end) { Date.parse("2025-11-03").end_of_day }

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
           created_at: Date.parse("2025-11-02"),
           locale: "en"
  end
  let!(:gyr_intake_2) { create :intake, email_address: "laxmi@example.com", email_notification_opt_in: "yes", email_address_verified_at: Time.current, created_at: Date.parse("2025-11-02") }
  let!(:gyr_intake_3) { create :intake, email_address: "vic@example.com", email_notification_opt_in: "yes", email_address_verified_at: Time.current, created_at: Date.parse("2025-11-02") }
  let!(:gyr_intake_4) { create :intake, email_address: "montana@example.com", email_notification_opt_in: "yes", email_address_verified_at: Time.current, created_at: Date.parse("2025-11-02") }
  let!(:gyr_intake_5) { create :intake, email_address: "sky@example.com", email_notification_opt_in: "yes", email_address_verified_at: Time.current, created_at: Date.parse("2025-11-02") }

  let!(:signup) {
    create :signup,
           name: "Chris",
           email_address: "chris@example.com",
           phone_number: "+15550001111",
           created_at: Date.parse("2025-11-02")
  }

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
           created_at: Date.parse("2025-11-02")
  end
  let(:gyr_min_id) { Intake::GyrIntake.contactable.where(created_at: window_start..window_end).minimum(:id) }
  let(:gyr_max_id) { Intake::GyrIntake.contactable.where(created_at: window_start..window_end).maximum(:id) }

  before do
    task.reenable
  end

  around do |example|
    original_start = ENV["START_DATE"]
    original_end = ENV["END_DATE"]
    original_chunk = ENV["CHUNK_SIZE"]

    ENV["START_DATE"] = "2025-11-01"
    ENV["END_DATE"] = "2025-11-03"
    ENV["CHUNK_SIZE"] = "5000"

    example.run
  ensure
    ENV["START_DATE"] = original_start
    ENV["END_DATE"] = original_end
    ENV["CHUNK_SIZE"] = original_chunk
  end

  it "enqueues jobs for GYR, Signups, and each StateFile intake class using the env date window and chunk size" do
    expect(Campaign::SyncContacts::BackfillGyrIntakesJob)
      .to receive(:perform_later).with(gyr_min_id, gyr_max_id, window_start.to_date, window_end.to_date)

    expect(Campaign::SyncContacts::BackfillSignupsJob)
      .to receive(:perform_later).with(signup.id, signup.id, window_start.to_date, window_end.to_date)

    expect(Campaign::SyncContacts::BackfillStateFileIntakesJob)
      .to receive(:perform_later)
            .with("StateFileAzIntake", state_intake.id, state_intake.id, window_start.to_date, window_end.to_date)

    task.invoke
  end

  context "when scope is empty" do
    it "does not enqueue jobs" do
      ENV["START_DATE"] = "2025-11-15" # no intakes/signups created between these times
      ENV["END_DATE"] = "2025-11-20"
      ENV["CHUNK_SIZE"] = "10"

      expect(Campaign::SyncContacts::BackfillGyrIntakesJob).not_to receive(:perform_later)
      expect(Campaign::SyncContacts::BackfillSignupsJob).not_to receive(:perform_later)
      expect(Campaign::SyncContacts::BackfillStateFileIntakesJob).not_to receive(:perform_later)

      task.invoke
    end
  end

  context "when chunk size is 2" do
    let(:gyr_min_id) { Intake::GyrIntake.contactable.where(created_at: window_start..window_end).minimum(:id) }
    let(:gyr_max_id) { Intake::GyrIntake.contactable.where(created_at: window_start..window_end).maximum(:id) }

    it "splits ranges according to CHUNK_SIZE" do
      ENV["CHUNK_SIZE"] = "2"

      expect(Campaign::SyncContacts::BackfillGyrIntakesJob).to receive(:perform_later).with(gyr_min_id, (gyr_min_id + 1), window_start.to_date, window_end.to_date)
      expect(Campaign::SyncContacts::BackfillGyrIntakesJob).to receive(:perform_later).with((gyr_min_id + 2), (gyr_min_id + 3), window_start.to_date, window_end.to_date)
      expect(Campaign::SyncContacts::BackfillGyrIntakesJob).to receive(:perform_later).with(gyr_max_id, gyr_max_id, window_start.to_date, window_end.to_date)
      task.invoke
    end
  end
end