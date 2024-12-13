require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Md::Documents::Md502Cr, required_schema: "md" do
  describe ".document" do
    let(:primary_birth_date) { Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1) }
    let(:intake) { create(:state_file_md_intake, filing_status: "single", primary_birth_date: primary_birth_date) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    before do
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_deduction_method).and_return("S")
    end

    it "generates a valid xml" do
      expect(build_response.errors).to be_empty
    end

    describe ".document" do
      before do
        intake.direct_file_data.fed_agi = 100
      end

      context "ChildAndDependentCare section" do
        before do
          intake.direct_file_data.fed_credit_for_child_and_dependent_care_amount = 10
        end
        context "when all relevant values are present in the DF XML" do
          it "outputs child and dependent care amounts" do
            expect(xml.at("Form502CR ChildAndDependentCare FederalAdjustedGrossIncome").text.to_i).to eq(100)
            expect(xml.at("Form502CR ChildAndDependentCare FederalChildCareCredit").text.to_i).to eq(10)
            expect(xml.at("Form502CR ChildAndDependentCare DecimalAmount").text.to_d).to eq(0.32)
            expect(xml.at("Form502CR ChildAndDependentCare Credit").text.to_i).to eq(3)
          end
        end
      end

      context "Senior Section" do
        context "when all relevant values are present in the DF XML" do
          it "outputs child and dependent care amounts"  do
            expect(xml.at("Form502CR Senior Credit").text.to_i).to eq(1_000)
          end
        end
      end

      context "Summary Section" do
        before do
          allow_any_instance_of(Efile::Md::Md502crCalculator).to receive(:calculate_part_aa_line_2).and_return 100
          allow_any_instance_of(Efile::Md::Md502crCalculator).to receive(:calculate_part_aa_line_13).and_return 200
        end
        it "outputs all relevant values" do
          expect(xml.at("Form502CR Summary ChildAndDependentCareCr").text.to_i).to eq(100)
          expect(xml.at("Form502CR Summary SeniorCr").text.to_i).to eq(200)
          expect(xml.at("Form502CR Summary TotalCredits").text.to_i).to eq(300)
        end
      end

      context "Refundable Section" do
        before do
          allow_any_instance_of(Efile::Md::Md502crCalculator).to receive(:calculate_part_cc_line_7).and_return 100
          allow_any_instance_of(Efile::Md::Md502crCalculator).to receive(:calculate_part_cc_line_8).and_return 200
        end
        it "outputs all relevant values" do
          expect(xml.at("Form502CR Refundable ChildAndDependentCareCr").text.to_i).to eq(100)
          expect(xml.at("Form502CR Refundable MDChildTaxCr").text.to_i).to eq(200)
          expect(xml.at("Form502CR Refundable TotalCredits").text.to_i).to eq(300)
        end
      end

      context "when deduction method is N" do
        before do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_deduction_method).and_return("N")
        end

        it "does not output parts B, M or AA but still outputs part CC" do
          expect(xml.at("Form502CR ChildAndDependentCare")).to be_nil
          expect(xml.at("Form502CR Senior")).to be_nil
          expect(xml.at("Form502CR Summary")).to be_nil
          expect(xml.at("Form502CR Refundable")).not_to be_nil
        end
      end
    end
  end
end
