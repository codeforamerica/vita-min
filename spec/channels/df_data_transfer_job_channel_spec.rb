require 'rails_helper'

RSpec.describe DfDataTransferJobChannel, type: :channel do
  let(:intake) { create(:state_file_az_intake) }
  before do
    intake.update(raw_direct_file_data: direct_file_data)
    stub_connection current_state_file_intake: intake
  end

  context "without direct file data" do
    let(:direct_file_data) { nil }

    it 'does not broadcast job complete' do
      expect do
        subscribe
      end.not_to have_broadcasted_to(DfDataTransferJobChannel.broadcasting_for(intake))
      expect(subscription).to have_stream_for(intake)
    end
  end

  context "with direct file data" do
    let(:direct_file_data) { StateFile::DirectFileApiResponseSampleService.new.old_xml_sample }

    it 'broadcasts job complete' do
      expect do
        subscribe
      end.to have_broadcasted_to(DfDataTransferJobChannel.broadcasting_for(intake)).with(["The job is complete"])
      expect(subscription).to have_stream_for(intake)
    end
  end
end
