require "rails_helper"

describe SubmissionBuilder::Documents::Scenario5Irs8863 do
  let(:submission) { TestSubmissions::Scenario5Submission.create_submission }
  before do
    allow(EnvironmentCredentials).to receive(:dig).with(:irs, :sin).and_return "11111111"
  end

  context 'with the scenario 5 data' do
    it 'conforms to the schema' do
      expect(described_class.build(submission)).to be_valid
    end
  end
end