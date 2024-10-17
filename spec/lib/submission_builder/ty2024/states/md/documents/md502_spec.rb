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

      context "County information" do

        before do
          intake.residence_county = "Allegany"
          intake.political_subdivision = "Town Of Barton"
          intake.subdivision_code = "0101"
        end

        it "output correct information" do
          expect(xml.at("Form502 MarylandSubdivisionCode").text).to eq("0101")
          expect(xml.at("Form502 CityTownOrTaxingArea").text).to eq("Town Of Barton")
          expect(xml.at("Form502 MarylandCounty").text).to eq("AL")
        end
      end

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
          expect(xml.document.at('FilingStatus MarriedFilingSeparately')&.text).to eq "X"
        end
      end

      context "hoh filer" do
        let(:intake) { create(:state_file_md_intake, :head_of_household) }

        it "correctly fills answers" do
          expect(xml.document.at('FilingStatus HeadOfHousehold')&.text).to eq "X"
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
    end
  end
end