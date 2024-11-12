require 'rails_helper'
describe SubmissionBuilder::Ty2024::States::Md::Documents::Md502Su, required_schema: "md" do
  describe ".document" do
    let(:intake) { create(:state_file_md_intake) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    it "generates a valid xml" do
      expect(build_response.errors).to be_empty
    end

    describe ".document" do
      context "Subtractions" do
        context "when there is no interest report" do
          it "outputs the total subtraction amount" do
            expect(xml.at("Form502SU Subtractions Total").text.to_i).to eq(0)
          end
        end

        context "when there is an interest report" do
          let(:intake) { create(:state_file_md_intake, :df_data_1099_int) }
          it "outputs the total subtraction amount" do
            expect(xml.at("Form502SU Subtractions Total").text.to_i).to eq(2)
          end
        end
      end
    end
  end
end
