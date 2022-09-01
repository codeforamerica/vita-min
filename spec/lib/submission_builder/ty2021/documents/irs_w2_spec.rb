require "rails_helper"

describe SubmissionBuilder::Ty2021::Documents::IrsW2 do
  let(:filing_status) { "married_filing_jointly" }
  let(:intake) { create :ctc_intake }
  let(:submission) { create :efile_submission, :ctc, filing_status: filing_status, tax_year: 2021, client: create(:client, intake: intake) }
  let(:primary_w2) { create :w2, intake: intake }
  let(:spouse_w2) { create :w2, intake: intake, legal_first_name: intake.spouse_first_name }

  it "conforms to the eFileAttachments schema 2021v5.2" do
    instance = described_class.new(submission, kwargs: { w2: primary_w2 })
    expect(instance.schema_version).to eq "2021v5.2"

    expect(described_class.build(submission, kwargs: { w2: primary_w2 })).to be_valid
  end
end