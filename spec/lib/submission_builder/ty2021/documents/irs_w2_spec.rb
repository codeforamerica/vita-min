require "rails_helper"

describe SubmissionBuilder::Ty2021::Documents::IrsW2 do
  let(:filing_status) { "married_filing_jointly" }
  let(:intake) { create :ctc_intake, :filled_out_ctc }
  let(:submission) { create :efile_submission, :ctc, filing_status: filing_status, tax_year: 2021, client: create(:client, intake: intake) }
  let(:primary_w2) { create :w2, intake: intake }
  let!(:w2_state_fields_group) do
    create(
      :w2_state_fields_group,
      w2: primary_w2,
      box15_state: 'CA',
      box15_employer_state_id_number: '1N45t',
      box16_state_wages: 12.89,
      box17_state_income_tax: 123.45,
      box18_local_wages: 5,
      box19_local_income_tax: 15,
      box20_locality_name: 'squibnocket'
    )
  end
  let!(:w2_box14) { create :w2_box14, w2: primary_w2, other_description: 'hi', other_amount: 65.43 }
  let(:spouse_w2) { create :w2, intake: intake, employee: 'spouse' }

  it "conforms to the eFileAttachments schema 2021v5.2" do
    instance = described_class.new(submission, kwargs: { w2: primary_w2 })
    expect(instance.schema_version).to eq "2021v5.2"

    submission_builder_response = described_class.build(submission, kwargs: { w2: primary_w2 })
    expect(submission_builder_response).to be_valid
    xml = Nokogiri::XML::Document.parse(submission_builder_response.document.to_xml)
    expect(xml.at('OtherDeductionsBenefitsGrp').at('Desc').text).to eq('hi')
    expect(xml.at('OtherDeductionsBenefitsGrp').at('Amt').text).to eq('65')
    expect(xml.at('StateAbbreviationCd').text).to eq("CA")
    expect(xml.at('EmployerStateIdNum').text).to eq("1N45t")
    expect(xml.at('StateWagesAmt').text).to eq("13")
    expect(xml.at('StateIncomeTaxAmt').text).to eq("123")
    expect(xml.at('LocalWagesAndTipsAmt').text).to eq("5")
    expect(xml.at('LocalIncomeTaxAmt').text).to eq("15")
    expect(xml.at('LocalityNm').text).to eq("squibnocket")
  end
end
