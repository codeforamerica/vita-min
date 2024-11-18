require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Nc::Documents::D400ScheduleS, required_schema: "nc" do
  describe ".document" do
    let(:intake) { create(:state_file_nc_intake, filing_status: "single") }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    context "calculating DedFedAGI" do
      before do
        intake.direct_file_data.fed_taxable_income = 323
        intake.direct_file_data.fed_taxable_ssb = 123
        intake.tribal_member = "yes"
        intake.tribal_wages_amount = 100.00
      end

      it "correctly fills answers" do
        expect(xml.document.at('DedFedAGI USInterestInc').text).to eq "323"
        expect(xml.document.at('DedFedAGI TaxPortSSRRB').text).to eq "123"
        expect(xml.document.at('DedFedAGI ExmptIncFedRecInd').text).to eq "100"
        expect(xml.document.at('DedFedAGI TotDedFromFAGI').text).to eq "546"
      end
    end
  end
end
