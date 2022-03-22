require "rails_helper"

describe SubmissionBuilder::TY2021::Form8812 do
  let(:filing_status) { "married_filing_jointly"}
  let(:submission) { create :efile_submission, :ctc, filing_status: filing_status, tax_year: 2021 }
  before do
    submission.intake.update(advance_ctc_amount_received: 900)
  end
  it "conforms to the eFileAttachments schema 2021v5.2" do
    instance = described_class.new(submission)
    expect(instance.schema_version).to eq "2021v5.2"

    expect(described_class.build(submission)).to be_valid
  end
end