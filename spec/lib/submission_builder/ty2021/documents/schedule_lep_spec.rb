require "rails_helper"

describe SubmissionBuilder::Ty2021::Documents::ScheduleLep, required_schema: "federal" do
  let(:submission) { create :efile_submission, :ctc, tax_year: 2021 }

  before do
    submission.intake.update(
      irs_language_preference: "spanish",
      primary_first_name: "Herbert",
      primary_last_name: "Mickeymousegoofyplutodonaldduckminniemouse",
      primary_ssn: "123456789"
    )
  end

  it "includes the correct nodes in the XML" do
    xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
    expect(xml.at("PersonNm").text).to eq "Herbert Mickeymousegoofyplutodonaldduckminniemouse".first(35)
    expect(xml.at("SSN").text).to eq "123456789"
    expect(xml.at("LanguagePreferenceCd").text).to eq "001"
  end

  it "conforms to the eFileAttachments schema 2021v5.2" do
    instance = described_class.new(submission)
    expect(instance.schema_version).to eq "2021v5.2"

    expect(described_class.build(submission)).to be_valid
  end
end