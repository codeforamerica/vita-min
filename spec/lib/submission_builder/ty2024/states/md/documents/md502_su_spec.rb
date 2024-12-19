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
        context "when the ab subtraction is present" do
          before do
            allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_ab).and_return(100)
          end
          it "outputs the XML for code ab" do
            expect(xml.at("Form502SU Subtractions OtherDetail Code").text).to eq("ab")
            expect(xml.at("Form502SU Subtractions OtherDetail Amount").text.to_i).to eq(100)
            expect(xml.at("Form502SU Subtractions Total").text.to_i).to eq(100)
          end
        end

        context "when the ab subtraction is not present" do
          before do
            allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_ab).and_return(0)
          end
          it "does not output the XML for code ab" do
            expect(xml.at("Form502SU Subtractions OtherDetail Code")).not_to be_present
            expect(xml.at("Form502SU Subtractions OtherDetail Amount")).not_to be_present
            expect(xml.at("Form502SU Subtractions Total").text.to_i).to eq(0)
          end
        end
      end
    end
  end
end
