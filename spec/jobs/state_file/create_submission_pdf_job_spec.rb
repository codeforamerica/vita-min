require "rails_helper"

describe StateFile::CreateSubmissionPdfJob do
  describe ".perform" do
    let(:submission) { create :efile_submission, :preparing, :ctc }
    let(:submission_double) { double }

    before do
      allow(EfileSubmission).to receive_message_chain(:includes, :find).and_return submission_double
      allow(submission_double).to receive(:generate_filing_pdf)
      allow(submission_double).to receive(:generate_verified_address)

    end


    context "generating the pdf" do
      it "verifies the address" do
        described_class.perform_now(submission.id)
        expect(submission_double).to have_received(:generate_verified_address)
      end

      it "creates a filing pdf" do
        described_class.perform_now(submission.id)
        expect(submission_double).to have_received(:generate_filing_pdf)
      end

      context "when the address cannot be verified" do
        before do
          allow(submission_double).to receive(:generate_verified_address).and_raise StandardError
        end

        it "rescues gracefully and continues the operation" do
          described_class.perform_now(submission.id)
          expect(submission_double).to have_received(:generate_verified_address)
          expect(submission_double).to have_received(:generate_filing_pdf)
        end
      end
    end

    context "when there is an error creating the irs 1040 and 8812 pdf" do
      before do
        allow(submission_double).to receive(:generate_filing_pdf).and_raise StandardError
        allow(submission_double).to receive(:transition_to!)
        allow(DatadogApi).to receive(:increment)
      end

      it "raises the error and logs in datadog counter" do
        expect {
          described_class.perform_now(submission.id)
        }.to raise_error(StandardError)
        expect(DatadogApi).to have_received(:increment).with("clients.pdf_generation_failed")
      end
    end
  end
end