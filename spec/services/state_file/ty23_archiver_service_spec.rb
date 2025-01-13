# frozen_string_literal: true

require "rails_helper"
require 'json'

RSpec.describe StateFile::Ty23ArchiverService do

  describe '#find_archiveables' do
    %w[az ny].each do |state_code|
      let(:batch_size) { 3 }
      let(:archiver) { described_class.new(state_code: state_code, batch_size: batch_size) }

      context 'when there are accepted intakes to archive' do
        let(:intake1) { create(archiver.data_source.table_name.singularize, created_at: Date.parse("2023-04-01"), hashed_ssn: "fake hashed ssn1") }
        let(:intake2) { create(archiver.data_source.table_name.singularize, created_at: Date.parse("2023-04-01"), hashed_ssn: "fake hashed ssn2") }
        let(:submission1) { create(:efile_submission, :for_state, :accepted, data_source: intake1, created_at: Date.parse("2023-04-01")) }
        let(:submission2) { create(:efile_submission, :for_state, :accepted, data_source: intake2, created_at: Date.parse("2023-04-01")) }

        before do
          submission1.efile_submission_transitions.last.update(created_at: Date.parse("2023-04-01"))
          submission2.efile_submission_transitions.last.update(created_at: Date.parse("2023-04-01"))
        end

        it 'finds them and sets them as the current batch' do
          archiver.find_archiveables
          expect(archiver.current_batch.count).to eq(2)
          expect(archiver.current_batch).to include(intake1)
          expect(archiver.current_batch).to include(intake2)
        end
      end

      context 'when there is an archiveable intake with the same email and hashed_ssn as an archived intake' do
        let(:intake1) { create(archiver.data_source.table_name.singularize, created_at: Date.parse("2023-04-01"), hashed_ssn: "fake hashed ssn") }
        let(:intake2) {
          create(archiver.data_source.table_name.singularize, created_at: Date.parse("2023-04-01"),
                 email_address: intake1.email_address, hashed_ssn: intake1.hashed_ssn)
        }
        let(:submission1) { create(:efile_submission, :for_state, :accepted, data_source: intake1, created_at: Date.parse("2023-04-01")) }
        let(:submission2) { create(:efile_submission, :for_state, :accepted, data_source: intake2, created_at: Date.parse("2023-04-01")) }
        let!(:archived_intake1) { create(:state_file_archived_intake, intake: intake1, archiver: archiver) }

        before do
          submission1.efile_submission_transitions.last.update(created_at: Date.parse("2023-04-01"))
          submission2.efile_submission_transitions.last.update(created_at: Date.parse("2023-04-01"))
        end

        it 'does not treat the match as archiveable' do
          archiver.find_archiveables
          expect(archiver.current_batch.count).to eq(0)
          expect(archiver.current_batch).not_to include(intake2)
        end
      end

      context 'when there are two archiveable intakes with the same hashed_ssn' do
        let(:intake1) { create(archiver.data_source.table_name.singularize, created_at: Date.parse("2023-04-01"), hashed_ssn: "fake hashed ssn") }
        let(:intake2) {
          create(archiver.data_source.table_name.singularize, created_at: Date.parse("2023-04-02"),
                 email_address: intake1.email_address, hashed_ssn: intake1.hashed_ssn)
        }
        let(:submission1) { create(:efile_submission, :for_state, :accepted, data_source: intake1, created_at: Date.parse("2023-04-01")) }
        let(:submission2) { create(:efile_submission, :for_state, :accepted, data_source: intake2, created_at: Date.parse("2023-04-02")) }

        before do
          submission1.efile_submission_transitions.last.update(created_at: Date.parse("2023-04-01"))
          submission2.efile_submission_transitions.last.update(created_at: Date.parse("2023-04-02"))
        end

        it 'does not treat the match as archiveable' do
          archiver.find_archiveables
          expect(archiver.current_batch.count).to eq(1)
          expect(archiver.current_batch).not_to include(intake1)
          expect(archiver.current_batch).to include(intake2)
        end
      end

      context 'when there are only non-accepted submissions' do
        let(:archiver) { described_class.new(state_code: state_code) }
        let!(:intake) { create("state_file_#{state_code}_intake".to_sym, created_at: Date.parse("2023-04-01"), hashed_ssn: "fake hashed ssn") }
        let!(:rejected_submission) { create(:efile_submission, :for_state, :rejected, data_source: intake, created_at: Date.parse("2023-04-01")) }
        let!(:resubmitted_submission) { create(:efile_submission, :for_state, :resubmitted, data_source: intake, created_at: Date.parse("2023-04-01")) }
        let!(:cancelled_submission) { create(:efile_submission, :for_state, :cancelled, data_source: intake, created_at: Date.parse("2023-04-01")) }
        let!(:waiting_submission) { create(:efile_submission, :for_state, :waiting, data_source: intake, created_at: Date.parse("2023-04-01")) }

        before do
          rejected_submission.efile_submission_transitions.last.update(created_at: Date.parse("2023-04-01"))
          resubmitted_submission.efile_submission_transitions.last.update(created_at: Date.parse("2023-04-01"))
          cancelled_submission.efile_submission_transitions.last.update(created_at: Date.parse("2023-04-01"))
          waiting_submission.efile_submission_transitions.last.update(created_at: Date.parse("2023-04-01"))
        end

        it 'makes an empty current batch' do
          archiver.find_archiveables
          expect(archiver.current_batch.count).to eq(0)
        end
      end

      context 'when a submission has already been archived' do
        let(:archiver) { described_class.new(state_code: state_code) }
        let(:intake) { create(archiver.data_source.table_name.singularize, created_at: Date.parse("2023-04-01"), hashed_ssn: "fake hashed ssn") }
        let(:submission) { create(:efile_submission, :for_state, :accepted, data_source: intake, created_at: Date.parse("2023-04-01")) }
        let!(:archived_intake) { create(:state_file_archived_intake, intake: intake, archiver: archiver) }

        before do
          submission.efile_submission_transitions.last.update(created_at: Date.parse("2023-04-01"))
        end

        it 'does not add it to the archiveable batch' do
          archiver.find_archiveables
          expect(archiver.current_batch.count).to eq(0)
        end
      end
    end
  end

  describe '#archive_batch' do
    %w[az ny].each do |state_code|

      describe 'when there is a current batch to archive' do
        let(:archiver) { described_class.new(state_code: state_code, batch_size: 5) }
        let!(:intake1) { create(archiver.data_source.table_name.singularize, :with_mailing_address, :with_submission_pdf, hashed_ssn: "fake hashed ssn1") }
        let!(:intake2) { create(archiver.data_source.table_name.singularize, :with_mailing_address, :with_submission_pdf, hashed_ssn: "fake hashed ssn2") }
        let(:mock_batch) { [intake1, intake2] }

        before do
          archiver.instance_variable_set(:@current_batch, mock_batch)
        end

        it 'creates an archived intake for each intake in the batch' do
          archived_ids = archiver.archive_batch
          expect(archived_ids.count).to eq(mock_batch.count)

          archived_ids.each do |archived_id|
            source_intake = archiver.data_source.find(archived_id)
            matching_archived_intakes = StateFileArchivedIntake.where(hashed_ssn: source_intake.hashed_ssn)

            # Verify there is exactly one archived intake for each source intake
            expect(matching_archived_intakes.count).to eq(1)
            archived_intake = matching_archived_intakes.first

            # Verify the email and mailing address information is populated correctly on the archived intake
            expect(archived_intake&.email_address).to eq(source_intake.email_address)
            expect(archived_intake&.mailing_street).to eq(source_intake.direct_file_data.mailing_street)
            expect(archived_intake&.mailing_apartment).to eq(source_intake.direct_file_data.mailing_apartment)
            expect(archived_intake&.mailing_city).to eq(source_intake.direct_file_data.mailing_city)
            expect(archived_intake&.mailing_state).to eq(source_intake.direct_file_data.mailing_state)
            expect(archived_intake&.mailing_zip).to eq(source_intake.direct_file_data.mailing_zip)

            # Verify that the PDF is attached to the archived intake and matches the source pdf
            expect(archived_intake&.submission_pdf&.download).to eq(source_intake.submission_pdf.download)
            expect(archived_intake&.submission_pdf&.filename).to eq(source_intake.submission_pdf.filename)
            expect(archived_intake&.submission_pdf&.content_type).to eq(source_intake.submission_pdf.content_type)

            # Ensure the PDF remains attached to the source intake
            expect(source_intake.submission_pdf.attached?).to be true
          end
        end
      end

      describe 'when there is no batch' do
        let(:archiver) { described_class.new(state_code: state_code, batch_size: 5) }

        before do
          archiver.instance_variable_set(:@current_batch, [])
        end

        it 'quietly archives nothing' do
          expect {
            archiver.archive_batch
          }.not_to change(StateFileArchivedIntake, :count)
        end
      end
    end
  end
end
