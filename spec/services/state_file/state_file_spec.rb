# frozen_string_literal: true

require "rails_helper"

RSpec.describe StateFile::Ty23ArchiverService do

  %w[az ny].each do |state_code|
    context 'when there are intakes to archive' do
      let!(:intake) { create("state_file_#{state_code}_intake".to_sym, created_at: Date.parse("1/5/23"), hashed_ssn: "fake hashed ssn") }
      let!(:submission) { create(:efile_submission, :for_state, :accepted, data_source: intake, created_at: Date.parse("1/5/23")) }

      let(:archiver) { described_class.new(state_code: state_code)}

      before do
        submission.efile_submission_transitions.last.update(created_at: Date.parse("1/5/23"))
      end

      it 'finds them and inserts appropriate records into the archived intakes table' do
        archiver.find_archiveables
        expect(archiver.current_batch.count).to be 1
        expect(archiver.current_batch.last["hashed_ssn"]).to eq intake.hashed_ssn
      end
    end
  end

end
