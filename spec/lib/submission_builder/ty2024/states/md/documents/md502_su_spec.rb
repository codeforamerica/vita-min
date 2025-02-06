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
        context "individual code letter tests" do
          Efile::Md::Md502SuCalculator::CALCULATED_FIELDS_AND_CODE_LETTERS.values.each do | code_letter|
            code_letter_sym = "calculate_line_#{code_letter}".to_sym.downcase

            context "when the #{code_letter} subtraction is present" do
              before do
                allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(code_letter_sym).and_return(100)
              end
              it "outputs the XML for code #{code_letter.downcase}" do
                expect(xml.at("Form502SU Subtractions OtherDetail Code").text).to eq(code_letter)
                expect(xml.at("Form502SU Subtractions OtherDetail Amount").text.to_i).to eq(100)
                expect(xml.at("Form502SU Subtractions Total").text.to_i).to eq(100)
              end
            end

            context "when the #{code_letter} subtraction is not present" do
              before do
                allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(code_letter_sym).and_return(0)
              end
              it "does not output the XML for code #{code_letter.downcase}" do
                expect(xml.at("Form502SU Subtractions OtherDetail Code")).not_to be_present
                expect(xml.at("Form502SU Subtractions OtherDetail Amount")).not_to be_present
                expect(xml.at("Form502SU Subtractions Total").text.to_i).to eq(0)
              end
            end
          end
        end

        context "multiple code letters" do
          before do
            Efile::Md::Md502SuCalculator::CALCULATED_FIELDS_AND_CODE_LETTERS.values.each do |code_letter|
              allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive("calculate_line_#{code_letter}".downcase.to_sym).and_return(100)
            end
          end

          Efile::Md::Md502SuCalculator::CALCULATED_FIELDS_AND_CODE_LETTERS.values.each_with_index do |code_letter, i|
            it "outputs the XML for code #{code_letter.downcase}" do
              expect(xml.search("Form502SU Subtractions OtherDetail Code")[i].text).to eq(code_letter)
              expect(xml.search("Form502SU Subtractions OtherDetail Amount")[i].text.to_i).to eq(100)
            end
          end

          it "outputs the XML for the subtractions total" do
            expect(xml.search("Form502SU Subtractions Total").text.to_i).to eq(200)
          end
        end
      end
    end
  end
end
