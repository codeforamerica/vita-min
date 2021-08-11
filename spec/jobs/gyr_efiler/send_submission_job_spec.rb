require 'rails_helper'

RSpec.describe GyrEfiler::SendSubmissionJob, type: :job do
  before do
    allow(Rails.application.config).to receive(:efile_environment).and_return("test")
  end

  describe '#perform' do
    let!(:submission) { create(:efile_submission, :queued, submission_bundle: { filename: "sensible-filename.zip", io: StringIO.new("i am a zip file") }) }

    let(:successful_result) do
      <<~RESULT
        <?xml version="1.0" encoding="UTF-8"?>
        <SubmissionReceiptList xmlns="http://www.irs.gov/efile" xmlns:efile="http://www.irs.gov/efile">
           <Cnt>1</Cnt>
           <SubmissionReceiptGrp>
              <SubmissionId>#{submission.irs_submission_id}</SubmissionId>
              <SubmissionReceivedTs>2021-07-15T12:32:59-04:00</SubmissionReceivedTs>
           </SubmissionReceiptGrp>
        </SubmissionReceiptList>
      RESULT
    end

    it 'invokes the GyrEfilerService and moves the state forward' do
      allow(Efile::GyrEfilerService).to receive(:run_efiler_command).and_return(successful_result)

      expect do
        described_class.perform_now(submission)
      end.to change { submission.current_state }.to("transmitted")
      expect(submission.efile_submission_transitions.last.metadata["receipt"]).to eq(successful_result)

      expect(Efile::GyrEfilerService).to have_received(:run_efiler_command).with("test", "submit", match(%r{.*[/]#{submission.submission_bundle.filename}\z}))
    end

    context 'when the submission fails for an unknown reason' do
      let(:failure_result) { "Java exception: UnexpectedFailureException at line Unknown" }

      it 'transitions into failed state' do
        allow(Efile::GyrEfilerService).to receive(:run_efiler_command).and_return(failure_result)

        expect do
          described_class.perform_now(submission)
        end.to change { submission.current_state }.to("failed")
        expect(submission.efile_submission_transitions.last.efile_errors.length).to eq(1)

        expect(submission.efile_submission_transitions.last.metadata["raw_response"]).to eq(failure_result)
      end
    end

    context 'when the efiler raises an exception' do
      it 'transitions into failed state' do
        exception = StandardError.new("A problem happened with your computer")
        allow(Efile::GyrEfilerService).to receive(:run_efiler_command).and_raise(exception)

        expect do
          described_class.perform_now(submission)
        end.to change { submission.current_state }.to("failed").and raise_error(exception)
        expect(submission.efile_submission_transitions.last.efile_errors.length).to eq 1
        expect(submission.efile_submission_transitions.last.metadata["raw_response"]).to eq("#<StandardError: A problem happened with your computer>")
      end
    end
  end
end
