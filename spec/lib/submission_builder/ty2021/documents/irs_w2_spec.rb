require "rails_helper"

describe SubmissionBuilder::Ty2021::Documents::IrsW2 do
  let(:filing_status) { "married_filing_jointly" }
  let(:intake) { build :ctc_intake, :filled_out_ctc }
  let(:submission) { create :efile_submission, :ctc, filing_status: filing_status, tax_year: 2021, client: intake.client }
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
    box14_node = xml.at('OtherDeductionsBenefitsGrp')
    expect(box14_node.at('Desc').text).to eq('hi')
    expect(box14_node.at('Amt').text).to eq('65')

    box15_node = xml.at('W2StateLocalTaxGrp')
    expect(box15_node.at('StateAbbreviationCd').text).to eq("CA")
    expect(box15_node.at('EmployerStateIdNum').text).to eq("1N45t")
    expect(box15_node.at('StateWagesAmt').text).to eq("13")
    expect(box15_node.at('StateIncomeTaxAmt').text).to eq("123")
    expect(box15_node.at('LocalWagesAndTipsAmt').text).to eq("5")
    expect(box15_node.at('LocalIncomeTaxAmt').text).to eq("15")
    expect(box15_node.at('LocalityNm').text).to eq("squibnocket")
  end

  describe 'EmployerNameControlTxt' do
    let(:primary_w2) { create :w2, intake: intake, employer_name: 'a & - 2 bananas' }

    it "upcases and removes spaces and whatnot from employer_name to produce EmployerNameControlTxt" do
      instance = described_class.new(submission, kwargs: { w2: primary_w2 })
      expect(instance.schema_version).to eq "2021v5.2"

      submission_builder_response = described_class.build(submission, kwargs: { w2: primary_w2 })
      expect(submission_builder_response).to be_valid
      xml = Nokogiri::XML::Document.parse(submission_builder_response.document.to_xml)
      expect(xml.at('EmployerNameControlTxt').text).to eq('A&-2')
    end
  end

  context "when there are not many box14 or box15 values present" do
    let!(:w2_state_fields_group) do
      create(
        :w2_state_fields_group,
        w2: primary_w2,
        box15_state: nil,
        box15_employer_state_id_number: nil,
        box16_state_wages: nil,
        box17_state_income_tax: nil,
        box18_local_wages: nil,
        box19_local_income_tax: nil,
        box20_locality_name: nil,
      )
    end
    let!(:w2_box14) { create :w2_box14, w2: primary_w2, other_description: nil, other_amount: nil }

    it "renders some XML without incident" do
      instance = described_class.new(submission, kwargs: { w2: primary_w2 })
      expect(instance.schema_version).to eq "2021v5.2"

      submission_builder_response = described_class.build(submission, kwargs: { w2: primary_w2 })
      expect(submission_builder_response).to be_valid
      xml = Nokogiri::XML::Document.parse(submission_builder_response.document.to_xml)
      #
      expect(xml.at('OtherDeductionsBenefitsGrp')).to be_nil

      box15_node = xml.at('W2StateLocalTaxGrp')
      expect(box15_node.at('StateAbbreviationCd')).to be_nil
      expect(box15_node.at('EmployerStateIdNum')).to be_nil
      expect(box15_node.at('StateWagesAmt')).to be_nil
      expect(box15_node.at('StateIncomeTaxAmt')).to be_nil
      expect(box15_node.at('LocalWagesAndTipsAmt')).to be_nil
      expect(box15_node.at('LocalIncomeTaxAmt')).to be_nil
      expect(box15_node.at('LocalityNm')).to be_nil
    end
  end
end
