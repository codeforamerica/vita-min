require 'rails_helper'

describe Efile::PollForAcknowledgmentsService do
  describe ".run" do
    context "with an EfileSubmission that is in the transmitted state" do

      let!(:efile_submission) { create(:efile_submission, :transmitted, submission_bundle: { filename: "sensible-filename.zip", io: StringIO.new("i am a zip file") }) }

      before do
        efile_submission.update!(irs_submission_id: "9999992021197yrv4rvl")
        allow(Efile::GyrEfilerService).to receive(:run_efiler_command).with("acks", efile_submission.irs_submission_id).and_return("")
      end

      context "when the IRS has no acknowledgement ready for this submission" do
        it "does not change the state" do
          Efile::PollForAcknowledgmentsService.run
          expect(efile_submission.reload.current_state).to eq("transmitted")
        end
      end

      context "when the IRS has an acknowledgement ready for this submission" do
        before do
          allow(Efile::GyrEfilerService).to receive(:run_efiler_command)
            .with("acks", efile_submission.irs_submission_id)
            .and_return expected_irs_return_value
        end

        let(:first_ack) do
          Nokogiri::XML(expected_irs_return_value).css("Acknowledgement").first.to_xml
        end

        context "and it is a rejection" do
          let(:expected_irs_return_value) { file_fixture("irs_acknowledgement_rejection.xml").read }

          it "changes the state from transmitted to rejected" do
            Efile::PollForAcknowledgmentsService.run
            expect(efile_submission.current_state).to eq("rejected")
            expect(efile_submission.efile_submission_transitions.last.metadata['raw_response']).to eq(first_ack)
          end
        end

        context "and it is an acceptance" do
          let(:expected_irs_return_value) { file_fixture("irs_acknowledgement_acceptance.xml").read }

          it "changes the state from transmitted to accepted" do
            Efile::PollForAcknowledgmentsService.run
            expect(efile_submission.current_state).to eq("accepted")
            expect(efile_submission.efile_submission_transitions.last.metadata['raw_response']).to eq(first_ack)
          end
        end
      end
    end
  end
end
