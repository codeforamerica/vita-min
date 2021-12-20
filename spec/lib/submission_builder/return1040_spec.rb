require "rails_helper"

describe SubmissionBuilder::Return1040 do
  let(:submission) { create :efile_submission, :ctc, filing_status: "married_filing_jointly", tax_year: 2021 }

  before do
    submission.intake.update(
      primary_first_name: "Hubert Blaine ",
      primary_last_name: "Wolfeschlegelsteinhausenbergerdorff ",
      spouse_first_name: "Lisa",
      spouse_last_name: "Frank",
      primary_signature_pin: "12345",
      spouse_signature_pin: "54321",
      primary_signature_pin_at: DateTime.new(2021, 4, 20, 16, 20),
      spouse_signature_pin_at: DateTime.new(2021, 4, 20, 16, 20)
    )
  end

  context ".build" do
    it "conforms to the Return1040 schema" do
      expect(described_class.build(submission, documents: ["adv_ctc_irs1040"])).to be_valid
    end
  end
end
