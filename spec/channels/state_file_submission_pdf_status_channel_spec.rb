require 'rails_helper'

RSpec.describe StateFileSubmissionPdfStatusChannel, type: :channel do
  let(:intake) { create(:state_file_az_intake) }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  context "before the bundle submission pdf job run" do
    it 'does not broadcast intake ready' do
      expect do
        subscribe
      end.to have_broadcasted_to(StateFileSubmissionPdfStatusChannel.broadcasting_for(intake))
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
