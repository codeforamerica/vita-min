require 'rails_helper'

RSpec.describe StateFileSubmissionPdfStatusChannel, type: :channel do
  let(:intake) { create(:state_file_az_intake) }

  before do
    allow(subject).to receive(:current_state_file_intake).and_return(intake)
  end

  context "before the bundle submission pdf job run" do
    it 'does not broadcast intake ready' do
      expect do
        subscribe
      end.to have_broadcasted_to(StateFileSubmissionPdfStatusChannel.broadcasting_for(intake))
    end
  end
end
