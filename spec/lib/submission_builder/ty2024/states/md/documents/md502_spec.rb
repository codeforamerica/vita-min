require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Md::Documents::Md502, required_schema: "md" do
  describe ".document" do
    let(:intake) { create(:state_file_md_intake, filing_status: "single") }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    describe ".document" do
      context "basic structure" do
        it "constructs the correct wrapping tags" do
          expect(xml.children.count).to eq 1
          expect(xml.children[0].name).to eq "Form502"
          expect(xml.at("Form502").attr("documentId")).to eq "Form502"
        end
      end

      context "single filer" do
        it "correctly fills answers" do
          expect(xml.document.at('FilingStatus Single')&.text).to eq "X"
          expect(xml.document.at('DaytimePhoneNumber')&.text).to eq "5551234567"
        end
      end

      context "mfj filer" do
        let(:intake) { create(:state_file_md_intake, :with_spouse) }

        it "correctly fills answers" do
          expect(xml.document.at('FilingStatus Joint')&.text).to eq "X"
        end
      end

      context "mfs filer" do
        let(:intake) { create(:state_file_md_intake, :with_spouse, filing_status: "married_filing_separately") }

        it "correctly fills answers" do
          expect(xml.document.at('FilingStatus MarriedFilingSeparately').text).to eq "X"
          expect(xml.document.at('FilingStatus MarriedFilingSeparately')['spouseSSN']).to eq "600000030"
        end
      end

      context "hoh filer" do
        let(:intake) { create(:state_file_md_intake, :head_of_household) }

        it "correctly fills answers" do
          expect(xml.document.at('FilingStatus HeadOfHousehold').text).to eq "X"
        end
      end

      context "qw filer" do
        let(:intake) { create(:state_file_md_intake, :qualifying_widow) }
        it "correctly fills answers" do
          expect(xml.document.at('FilingStatus QualifyingWidow')&.text).to eq "X"
        end
      end

      context "dependent filer" do
        let(:intake) { create(:state_file_md_intake, :claimed_as_dependent) }

        it "correctly fills answers" do
          expect(xml.document.at('FilingStatus DependentTaxpayer')&.text).to eq "X"
        end
      end

      context "exemptions stuff" do
        context "when there are no exemptions" do
          it "omits the whole exemptions section" do
            [
              :get_dependent_exemption_count,
              :calculate_dependent_exemption_amount
            ].each do |method|
              allow_any_instance_of(Efile::Md::Md502Calculator).to receive(method).and_return 0
            end

            expect(xml.document.at("Exemptions")).to be_nil
          end
        end

        context "dependents section" do
          before do
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:get_dependent_exemption_count).and_return dependent_count
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_dependent_exemption_amount).and_return dependent_exemption_amount
          end

          context "when there are values" do
            let(:dependent_count) { 2 }
            let(:dependent_exemption_amount) { 6400 }

            it "fills out the dependent exemptions correctly" do
              expect(xml.document.at("Exemptions Dependents Count")&.text).to eq dependent_count.to_s
              expect(xml.document.at("Exemptions Dependents Amount")&.text).to eq dependent_exemption_amount.to_s
            end
          end

          context "when there are no values" do
            let(:dependent_count) { 0 }
            let(:dependent_exemption_amount) { 0 }

            it "omits the whole section" do
              expect(xml.document.at("Exemptions Dependents")).to be_nil
            end
          end
        end
      end
    end
  end
end