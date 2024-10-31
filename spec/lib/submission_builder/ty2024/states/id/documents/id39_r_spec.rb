require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Id::Documents::Id39R, required_schema: "id" do
  describe ".document" do
    let(:intake) { create(:state_file_id_intake) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    context "fills out Interest Income from Obligations of the US" do
      let(:intake) { create(:state_file_id_intake, :df_data_1099_int) }
      it "correctly fills answers" do
        expect(xml.at("IncomeUSObligations").text).to eq "2"
      end
    end
  end
end