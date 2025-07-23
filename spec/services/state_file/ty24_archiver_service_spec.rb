# frozen_string_literal: true

require "rails_helper"
require 'json'

RSpec.describe StateFile::Ty24ArchiverService do
  describe "#archived!" do
    context "when archive-able state-file intakes exists" do
      let!(:archiveable_az_intake) do
        create :state_file_az_intake,
               :with_mailing_address, :with_submission_pdf,
               hashed_ssn: "ierueiwru8ndjfn",
               email_address: "zeus@example.com",
               contact_preference: "text"
      end
      let!(:submission_1) { create(:efile_submission, :for_state, :accepted, data_source: archiveable_az_intake) }

      before do
        submission_1.efile_submission_transitions.where(to_state: "accepted").update(created_at: Date.parse("2025-4-1"))
      end

      it "creates new StateFileArchivedIntake with data from intake copied over" do
        expect {
          StateFile::Ty24ArchiverService.archive!(state_code: 'az')
        }.to change(StateFileArchivedIntake, :count).by 1
        archived_intake = StateFileArchivedIntake.last
        expect(archived_intake.state_code).to eq('az')
        expect(archived_intake.tax_year).to eq(2024)

        # Verify information from intake has populated onto the archived intake correctly
        expect(archived_intake.hashed_ssn).to eq("ierueiwru8ndjfn")
        expect(archived_intake.email_address).to eq("zeus@example.com")
        expect(archived_intake.contact_preference).to eq("text")
        expect(archived_intake.mailing_street).to eq(archiveable_az_intake.direct_file_data.mailing_street)
        expect(archived_intake.mailing_apartment).to eq(archiveable_az_intake.direct_file_data.mailing_apartment)
        expect(archived_intake.mailing_city).to eq(archiveable_az_intake.direct_file_data.mailing_city)
        expect(archived_intake.mailing_state).to eq(archiveable_az_intake.direct_file_data.mailing_state)
        expect(archived_intake.mailing_zip).to eq(archiveable_az_intake.direct_file_data.mailing_zip)

        # Verify that the PDF is attached to the archived intake and matches the source pdf
        expect(archived_intake.submission_pdf.download).to eq(archiveable_az_intake.submission_pdf.download)
        expect(archived_intake.submission_pdf.filename).to eq(archiveable_az_intake.submission_pdf.filename)
        expect(archived_intake.submission_pdf.content_type).to eq(archiveable_az_intake.submission_pdf.content_type)

        # Ensure the PDF remains attached to the source intake
        expect(archiveable_az_intake.submission_pdf.attached?).to be true
      end
    end

    context "when state-file intake is outside of the tax filing season" do
      let!(:intake) { create :state_file_az_intake, :with_mailing_address, :with_submission_pdf, hashed_ssn: "ierueiwru8ndjfn", email_address: "zeus@example.com", contact_preference: "text" }
      let!(:submission_1) { create(:efile_submission, :for_state, :accepted, data_source: intake) }
      before do
        submission_1.efile_submission_transitions.where(to_state: "accepted").update(created_at: Date.parse("2025-1-1"))
      end

      it "doesn't create a new StateFileArchivedIntake" do
        expect {
          StateFile::Ty24ArchiverService.archive!(state_code: 'az')
        }.to change(StateFileArchivedIntake, :count).by 0
      end
    end

    context "when an archived intake with same email address, tax year and state code already exists" do
      let!(:intake) { create :state_file_az_intake, :with_mailing_address, :with_submission_pdf, hashed_ssn: "ierueiwru8ndjfn", email_address: "zeus@example.com", contact_preference: "text" }
      let!(:submission_1) { create(:efile_submission, :for_state, :accepted, data_source: intake) }
      let!(:archived_intake){ create :state_file_archived_intake, email_address: "zeus@example.com", tax_year: 2024, state_code: "az" }
      before do
        submission_1.efile_submission_transitions.where(to_state: "accepted").update(created_at: Date.parse("2025-4-1"))
      end

      it "doesn't create a new StateFileArchivedIntake" do
        expect {
          StateFile::Ty24ArchiverService.archive!(state_code: 'az')
        }.to change(StateFileArchivedIntake, :count).by 0
      end
    end

    context "archived intake with same phone number, tax year and state code already exists" do
      let!(:intake) { create :state_file_az_intake, :with_mailing_address, :with_submission_pdf, hashed_ssn: "ierueiwru8ndjfn", phone_number: "+18286789900", contact_preference: "text" }
      let!(:submission_1) { create(:efile_submission, :for_state, :accepted, data_source: intake) }
      let!(:archived_intake){ create :state_file_archived_intake, phone_number: "+18286789900", tax_year: 2024, state_code: "az" }
      before do
        submission_1.efile_submission_transitions.where(to_state: "accepted").update(created_at: Date.parse("2025-4-1"))
      end

      it "doesn't create a new StateFileArchivedIntake" do
        expect {
          StateFile::Ty24ArchiverService.archive!(state_code: 'az')
        }.to change(StateFileArchivedIntake, :count).by 0
      end
    end

    context "most recent efile submission transition is not accepted" do
      let!(:intake) { create :state_file_az_intake, :with_mailing_address, :with_submission_pdf, hashed_ssn: "ierueiwru8ndjfn", phone_number: "+18286789900", contact_preference: "text" }
      let!(:submission_1) { create(:efile_submission, :for_state, :rejected, data_source: intake) }
      before do
        submission_1.efile_submission_transitions.where(to_state: "rejected").update(created_at: Date.parse("2025-4-1"))
      end

      it "doesn't create a new StateFileArchivedIntake" do
        expect {
          StateFile::Ty24ArchiverService.archive!(state_code: 'az')
        }.to change(StateFileArchivedIntake, :count).by 0
      end
    end

    context "archived intakes for other states exists" do
      let!(:intake) { create :state_file_az_intake, :with_mailing_address, :with_submission_pdf, hashed_ssn: "ierueiwru8ndjfn", phone_number: "+18286789900", contact_preference: "text" }
      let!(:submission_1) { create(:efile_submission, :for_state, :accepted, data_source: intake) }
      before do
        submission_1.efile_submission_transitions.where(to_state: "accepted").update(created_at: Date.parse("2025-4-1"))
      end

      it "doesn't create a new StateFileArchivedIntake" do
        expect {
          StateFile::Ty24ArchiverService.archive!(state_code: 'md')
        }.to change(StateFileArchivedIntake, :count).by 0
      end
    end

    context "calling an invalid state code" do
      let!(:intake) { create :state_file_az_intake, :with_mailing_address, :with_submission_pdf, hashed_ssn: "ierueiwru8ndjfn", phone_number: "+18286789900", contact_preference: "text" }
      let!(:submission_1) { create(:efile_submission, :for_state, :accepted, data_source: intake) }
      before do
        submission_1.efile_submission_transitions.where(to_state: "accepted").update(created_at: Date.parse("2025-4-1"))
      end

      it "raises an error" do
        expect { StateFile::Ty24ArchiverService.archive!(state_code: 'ny') }.to raise_error(ArgumentError)
      end
    end

    context "archive-able intake without a submission pdf" do
      let!(:intake) { create :state_file_az_intake, :with_mailing_address, :with_submission_pdf, hashed_ssn: "ierueiwru8ndjfn", phone_number: "+18286789900", contact_preference: "text" }
      let!(:submission_1) { create(:efile_submission, :for_state, :accepted, data_source: intake) }
      before do
        submission_1.efile_submission_transitions.where(to_state: "accepted").update(created_at: Date.parse("2025-4-1"))
        intake.submission_pdf.destroy
      end
      it "does not create a new StateFileArchivedIntake and prints warning" do
        expect {
          StateFile::Ty24ArchiverService.archive!(state_code: 'az')
        }.to change(StateFileArchivedIntake, :count).by 0
        expect(Rails.logger).not_to receive(:error).with("~~~~~No submission_pdf for intake_id: #{intake.id}~~~~~")
      end
    end
  end
end
