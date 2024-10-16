require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Md::Documents::Md502, required_schema: "md" do
  describe ".document" do
    let(:intake) { create(:state_file_md_intake, filing_status: "single") }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    it "generates a valid xml" do
      expect(build_response.errors).to be_empty
    end

    describe ".document" do

      context "Income section" do

        context "when all relevant values are present in the DF XML" do

          before do
            intake.direct_file_data.fed_agi = 100
            intake.direct_file_data.fed_wages_salaries_tips = 101
            intake.direct_file_data.fed_taxable_pensions = 102
            intake.direct_file_data.fed_taxable_income = 11_599
            intake.direct_file_data.fed_tax_exempt_interest = 2
          end

          it "outputs AGI amount" do
            expect(xml.at("Form502 Income FederalAdjustedGrossIncome").text.to_i).to eq(intake.direct_file_data.fed_agi)
          end

          it "outputs wages, salaries and tips amount" do
            expect(xml.at("Form502 Income WagesSalariesAndTips").text.to_i).to eq(intake.direct_file_data.fed_wages_salaries_tips)
          end

          it "outputs earned income amount" do
            expect(xml.at("Form502 Income EarnedIncome").text.to_i).to eq(intake.direct_file_data.fed_wages_salaries_tips)
          end

          it "outputs taxable pensions, IRAs and annuities amount" do
            expect(xml.at("Form502 Income TaxablePensionsIRAsAnnuities").text.to_i).to eq(intake.direct_file_data.fed_taxable_pensions)
          end

          context "when interest sums to greater than 11600" do
            it "includes the indicator" do
              expect(xml.at("Form502 Income InvestmentIncomeIndicator").text).to eq("X")
            end
          end

          context "when interest sums to less than 11600" do
            it "doesn't include the indicator" do
              intake.direct_file_data.fed_tax_exempt_interest = 1
              expect(xml.at("Form502 Income InvestmentIncomeIndicator")).not_to be_present
            end
          end
        end

        context "when some relevant values are missing from the DF XML" do
          before do
            intake.direct_file_data.create_or_destroy_df_xml_node(:fed_agi, nil)
            intake.direct_file_data.create_or_destroy_df_xml_node(:fed_wages_salaries_tips, nil)
            intake.direct_file_data.create_or_destroy_df_xml_node(:fed_taxable_pensions, nil)
            intake.direct_file_data.create_or_destroy_df_xml_node(:fed_taxable_income, nil)
            intake.direct_file_data.create_or_destroy_df_xml_node(:fed_tax_exempt_interest, nil)
          end

          it "populates the Income section correctly" do
            expect(xml.at("Form502 Income FederalAdjustedGrossIncome").text.to_i).to eq(0)
            expect(xml.at("Form502 Income WagesSalariesAndTips").text.to_i).to eq(0)
            expect(xml.at("Form502 Income EarnedIncome").text.to_i).to eq(0)
            expect(xml.at("Form502 Income TaxablePensionsIRAsAnnuities").text.to_i).to eq(0)
            expect(xml.at("Form502 Income InvestmentIncomeIndicator")).not_to be_present
          end
        end
      end

      context "single filer" do
        it "correctly fills answers" do
          expect(xml.document.at('ResidencyStatusPrimary')&.text).to eq "true"
          expect(xml.document.at("TaxPeriodBeginDt").text).to eq "2023-01-01"
          expect(xml.document.at("TaxPeriodEndDt").text).to eq "2023-12-31"
          expect(xml.document.at('FilingStatus')&.text).to eq "Single"
          expect(xml.document.at('DaytimePhoneNumber')&.text).to eq "5551234567"
        end
      end

      context "mfj filer" do
        let(:intake) { create(:state_file_md_intake, :with_spouse) }

        it "correctly fills answers" do
          expect(xml.document.at('FilingStatus')&.text).to eq "Joint"
        end
      end

      context "mfs filer" do
        let(:intake) { create(:state_file_md_intake, :with_spouse, filing_status: "married_filing_separately") }

        it "correctly fills answers" do
          expect(xml.document.at('FilingStatus')&.text).to eq "MarriedFilingSeparately"
          expect(xml.document.at('MFSSpouseSSN')&.text).to eq "600000030"
        end
      end

      context "hoh filer" do
        let(:intake) { create(:state_file_md_intake, :head_of_household) }

        it "correctly fills answers" do
          expect(xml.document.at('FilingStatus')&.text).to eq "HeadOfHousehold"
        end
      end

      context "qw filer" do
        let(:intake) { create(:state_file_md_intake, :qualifying_widow) }
        it "correctly fills answers" do
          expect(xml.document.at('FilingStatus')&.text).to eq "QualifyingWidow"
        end
      end

      context "dependent filer" do
        let(:intake) { create(:state_file_md_intake, :claimed_as_dependent) }

        it "correctly fills answers" do
          expect(xml.document.at('FilingStatus')&.text).to eq "DependentTaxpayer"
        end
      end
    end
  end
end