require 'rails_helper'

describe Efile::PollForAcknowledgmentsService do
  describe ".run" do
    context "with an EfileSubmission that is in the transmitted state" do
      let!(:efile_submission) { create(:efile_submission, :transmitted, submission_bundle: { filename: "sensible-filename.zip", io: StringIO.new("i am a zip file") }) }

      context "when the IRS has no acknowledgement ready for this submission" do
        it "does not change the state" do
          expect {
            Efile::PollForAcknowledgmentsService.run
          }.not_to change { efile_submission.reload.current_state }
        end
      end

      context "when the IRS has an acknowledgement ready for this submission" do

        context "and it is an acceptance" do
          xit "does not change the state" do
            expect {
              Efile::PollForAcknowledgmentsService.run
            }.to change { efile_submission.reload.current_state }.from("transmitted").to("accepted")
          end
        end
      end
    end
  end
end
