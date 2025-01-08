# frozen_string_literal: true

require "rails_helper"

RSpec.describe StateFile::Ty23ArchiverService do

  describe '#find_archiveables' do
    %w[az ny].each do |state_code|

      context 'when there are accepted intakes to archive' do
        let(:archiver) { described_class.new(state_code: state_code) }
        let!(:intake) { create("state_file_#{state_code}_intake".to_sym, created_at: Date.parse("1/5/23"), hashed_ssn: "fake hashed ssn") }
        let!(:submission) { create(:efile_submission, :for_state, :accepted, data_source: intake, created_at: Date.parse("1/5/23")) }

        before do
          submission.efile_submission_transitions.last.update(created_at: Date.parse("1/5/23"))
        end

        it 'finds them and sets them as the current batch' do
          archiver.find_archiveables
          expect(archiver.current_batch.count).to be 1
          expect(archiver.current_batch.last["hashed_ssn"]).to eq intake.hashed_ssn
        end
      end

      context 'when there are only non-accepted submissions' do
        let(:archiver) { described_class.new(state_code: state_code) }
        let!(:intake) { create("state_file_#{state_code}_intake".to_sym, created_at: Date.parse("1/5/23"), hashed_ssn: "fake hashed ssn") }
        let!(:rejected_submission) { create(:efile_submission, :for_state, :rejected, data_source: intake, created_at: Date.parse("1/5/23")) }
        let!(:resubmitted_submission) { create(:efile_submission, :for_state, :resubmitted, data_source: intake, created_at: Date.parse("1/5/23")) }
        let!(:cancelled_submission) { create(:efile_submission, :for_state, :cancelled, data_source: intake, created_at: Date.parse("1/5/23")) }
        let!(:waiting_submission) { create(:efile_submission, :for_state, :waiting, data_source: intake, created_at: Date.parse("1/5/23")) }

        before do
          rejected_submission.efile_submission_transitions.last.update(created_at: Date.parse("1/5/23"))
          resubmitted_submission.efile_submission_transitions.last.update(created_at: Date.parse("1/5/23"))
          cancelled_submission.efile_submission_transitions.last.update(created_at: Date.parse("1/5/23"))
          waiting_submission.efile_submission_transitions.last.update(created_at: Date.parse("1/5/23"))
        end

        it 'makes an empty current batch' do
          archiver.find_archiveables
          expect(archiver.current_batch.count).to be 0
        end
      end
    end
  end

  describe '#archive_batch' do
    %w[az ny].each do |state_code|
      context 'when there is a current batch to archive' do
        let(:archiver) { described_class.new(state_code: state_code) }
        let!(:intake) { create("state_file_#{state_code}_intake".to_sym, created_at: Date.parse("1/5/23"), hashed_ssn: "fake hashed ssn") }
        let!(:submission) { create(:efile_submission, :for_state, :accepted, data_source: intake, created_at: Date.parse("1/5/23")) }
        let!(:mock_batch) { [submission] }
        let(:test_pdf) { Rails.root.join("spec", "fixtures", "files", "document_bundle.pdf") }

        before do
          intake.submission_pdf.attach(
            io: File.open(test_pdf),
            filename: "test.pdf",
            content_type: 'application/pdf'
          )
          archiver.instance_variable_set(:@current_batch, mock_batch)
        end

        it 'creates an archived intake for each intake in the batch with an attached pdf' do
          archived_ids = archiver.archive_batch
          expect(archived_ids.count).to eq 1
          archived_ids.each do |id|
            expect(StateFileArchivedIntake.find(id).submission_pdf.attached?).to be true
          end
        end
      end
    end
  end

end
