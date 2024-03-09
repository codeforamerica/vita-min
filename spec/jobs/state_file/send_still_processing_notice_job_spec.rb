require 'rails_helper'

RSpec.describe StateFile::SendStillProcessingNoticeJob, type: :job do
  describe '#perform' do
    let(:intake) { create :state_file_ny_intake }
    let(:submission) { create(:efile_submission, :transmitted, data_source: intake) }
    let(:after_transition_messaging_service) { instance_double(StateFile::AfterTransitionMessagingService) }

    before do
      allow(StateFile::AfterTransitionMessagingService)
        .to receive(:new)
              .and_return(after_transition_messaging_service)
      allow(after_transition_messaging_service)
        .to receive(:send_efile_submission_still_processing_message)
    end

    context "client has still not been accepted or rejected" do
      it "sends the message" do
        described_class.perform_now(submission)

        expect(after_transition_messaging_service).to have_received(:send_efile_submission_still_processing_message)
      end
    end

    context "client has been accepted or rejected" do
      context "the accepted/rejected submission is the same one passed into the job" do
        before do
          submission.transition_to!(:accepted)
        end

        it "does not send the message" do
          described_class.perform_now(submission)

          expect(after_transition_messaging_service).not_to have_received(:send_efile_submission_still_processing_message)
        end
      end

      context "the accepted/rejected submission is a new one" do
        before do
          create(:efile_submission, :rejected, data_source: intake)
        end

        it "does not send the message" do
          described_class.perform_now(submission)

          expect(after_transition_messaging_service).not_to have_received(:send_efile_submission_still_processing_message)
        end
      end
    end
  end
end
