require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Md::Documents::Md502, required_schema: "md" do
  describe ".document" do
    let(:intake) { create(:state_file_md_intake, filing_status: "single", primary_birth_date: 65.years.ago) }
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

      context "County information" do
        context "with incorporated subdivision" do
          before do
            intake.residence_county = "Allegany"
            intake.political_subdivision = "Town Of Barton"
            intake.subdivision_code = "0101"
          end

          it "outputs correct information" do
            expect(xml.at("Form502 MarylandSubdivisionCode").text).to eq("0101")
            expect(xml.at("Form502 CityTownOrTaxingArea").text).to eq("Town Of Barton")
            expect(xml.at("Form502 MarylandCounty").text).to eq("AL")
          end
        end

        context "with unincorporated subdivision" do
          before do
            intake.residence_county = "Anne Arundel"
            intake.political_subdivision = "Anne Arundel - unincorporated"
            intake.subdivision_code = "0200"
          end

          it "outputs correct information without CityTownOrTaxingArea" do
            expect(xml.at("Form502 MarylandSubdivisionCode").text).to eq("0200")
            expect(xml.at("Form502 CityTownOrTaxingArea")).to be_nil
            expect(xml.at("Form502 MarylandCounty").text).to eq("AA")
          end
        end
      end

      context "Physical address" do
        before do
          intake.direct_file_data.mailing_street = "312 Poppy Street"
          intake.direct_file_data.mailing_apartment = "Apt B"
          intake.direct_file_data.mailing_city = "Annapolis"
          intake.direct_file_data.mailing_state = "MD"
          intake.direct_file_data.mailing_zip = "21401"
        end

        context "when user confirms that address from DF is correct" do
          before do
            intake.confirmed_permanent_address_yes!
            intake.direct_file_data.mailing_street = "312 Poppy Street"
            intake.direct_file_data.mailing_apartment = "Apt B"
            intake.direct_file_data.mailing_city = "Annapolis"
            intake.direct_file_data.mailing_zip = "21401"
          end

          it "outputs their DF address as their physical address" do
            expect(xml.at("MarylandAddress AddressLine1Txt").text).to eq "312 Poppy Street"
            expect(xml.at("MarylandAddress AddressLine2Txt").text).to eq "Apt B"
            expect(xml.at("MarylandAddress CityNm").text).to eq "Annapolis"
            expect(xml.at("MarylandAddress StateAbbreviationCd").text).to eq "MD"
            expect(xml.at("MarylandAddress ZIPCd").text).to eq "21401"
          end
        end

        context "when the user has entered a different permanent address" do
          before do
            intake.confirmed_permanent_address_no!
            intake.permanent_street = "313 Poppy Street"
            intake.permanent_apartment = "Apt A"
            intake.permanent_city = "Baltimore"
            intake.permanent_zip = "21201"
          end

          it "outputs their entered address as their physical address" do
            expect(xml.at("MarylandAddress AddressLine1Txt").text).to eq "313 Poppy Street"
            expect(xml.at("MarylandAddress AddressLine2Txt").text).to eq "Apt A"
            expect(xml.at("MarylandAddress CityNm").text).to eq "Baltimore"
            expect(xml.at("MarylandAddress StateAbbreviationCd").text).to eq "MD"
            expect(xml.at("MarylandAddress ZIPCd").text).to eq "21201"
          end
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
              :calculate_line_c_count,
              :calculate_line_c_amount,
              :calculate_line_a_count,
              :calculate_line_b_count
            ].each do |method|
              allow_any_instance_of(Efile::Md::Md502Calculator).to receive(method).and_return 0
            end

            expect(xml.document.at("Exemptions")).to be_nil
          end
        end

        context "line A section" do
          let(:intake) { create(:state_file_md_intake, :with_spouse, filing_status: "married_filing_jointly") }

          before do
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_a_primary).and_return "X"
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_a_spouse).and_return "X"
          end

          it "fills out line A" do
            expect(xml.document.at("Exemptions Primary Standard")&.text).to eq "X"
            expect(xml.document.at("Exemptions Spouse Standard")&.text).to eq "X"
          end
        end

        context "line B section" do
          let(:intake) { create(:state_file_md_intake, filing_status: "married_filing_jointly") }

          before do
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_primary_senior).and_return "X"
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_spouse_senior).and_return "X"
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_primary_blind).and_return "X"
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_spouse_blind).and_return "X"
          end

          it "fills out line B" do
            expect(xml.document.at("Exemptions Primary Over65")&.text).to eq "X"
            expect(xml.document.at("Exemptions Spouse Over65")&.text).to eq "X"
            expect(xml.document.at("Exemptions Primary Blind")&.text).to eq "X"
            expect(xml.document.at("Exemptions Spouse Blind")&.text).to eq "X"
          end
        end

        context "line C: dependents section" do
          before do
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_c_count).and_return dependent_count
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_c_amount).and_return dependent_exemption_amount
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

        context "line D section" do
          let(:intake) { create(:state_file_md_intake, filing_status: "married_filing_jointly", spouse_birth_date: 65.years.ago, primary_birth_date: 65.years.ago) }

          before do
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_d_count_total).and_return "X"
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_d_amount_total).and_return "X"
          end

          it "fills out line B" do
            expect(xml.document.at("Exemptions Total Count")&.text).to eq "X"
            expect(xml.document.at("Exemptions Total Amount")&.text).to eq "X"
          end
        end
      end

      context "healthcare coverage stuff" do
        context "truthy answers" do
          before do
            intake.update(primary_did_not_have_health_insurance: true)
            intake.update(primary_birth_date: DateTime.new(1975, 4, 12))
            intake.update(spouse_did_not_have_health_insurance: true)
            intake.update(spouse_birth_date: DateTime.new(1972, 11, 5))
            intake.update(authorize_sharing_of_health_insurance_info: "yes")
          end

          it "fills in the right lines" do
            expect(xml.document.at("MDHealthCareCoverage PriWithoutHealthCoverageInd")&.text).to eq "X"
            expect(xml.document.at("MDHealthCareCoverage PriDOB")&.text).to eq "1975-04-12"
            expect(xml.document.at("MDHealthCareCoverage SecWithoutHealthCoverageInd")&.text).to eq "X"
            expect(xml.document.at("MDHealthCareCoverage SecDOB")&.text).to eq "1972-11-05"
            expect(xml.document.at("MDHealthCareCoverage AuthorToShareInfoHealthExchInd")&.text).to eq "X"
          end
        end

        context "falsey answers" do
          before do
            intake.update(primary_did_not_have_health_insurance: false)
            intake.update(spouse_did_not_have_health_insurance: false)
            intake.update(authorize_sharing_of_health_insurance_info: "no")
          end

          it "fills in the right lines" do
            expect(xml.document.at("MDHealthCareCoverage PriWithoutHealthCoverageInd")).to be_nil
            expect(xml.document.at("MDHealthCareCoverage SecWithoutHealthCoverageInd")).to be_nil
            expect(xml.document.at("MDHealthCareCoverage AuthorToShareInfoHealthExchInd")).to be_nil
          end
        end
      end

      context "subtractions section" do
        context "when all relevant values are present in the DF XML" do
          before do
            allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_1).and_return 100
            intake.direct_file_data.total_qualifying_dependent_care_expenses = 1200
            intake.direct_file_data.fed_taxable_ssb = 240
          end

          it "outputs child and dependent care expenses" do
            expect(xml.at("Form502 Subtractions ChildAndDependentCareExpenses").text.to_i).to eq(intake.direct_file_data.total_qualifying_dependent_care_expenses)
          end

          it "outputs Taxable Social Security and RR benefits" do
            expect(xml.at("Form502 Subtractions SocialSecurityRailRoadBenefits").text.to_i).to eq(intake.direct_file_data.fed_taxable_ssb)
          end

          it "outputs the Subtractions from Form 502SU" do
            expect(xml.at("Form502 Subtractions Other").text.to_i).to eq(100)
          end
        end
      end

      context "deduction section" do
        it "fills out the deduction method from calculator" do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_deduction_method).and_return "S"
          expect(xml.at("Form502 Deduction Method").text).to eq "S"
        end

        context "amount" do
          before do
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_17).and_return 300
          end

          it "fills out the deduction amount from the calculator if method is standard" do
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_deduction_method).and_return "S"
            expect(xml.at("Form502 Deduction Amount").text).to eq "300"
          end

          it "leaves amount blank if method is not standard" do
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_deduction_method).and_return "N"
            expect(xml.at("Form502 Deduction Amount")).to be_nil
          end
        end
      end

      context "tax computation section" do
        before do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_18).and_return 40
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_19).and_return 50
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_20).and_return 60
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_21).and_return 70
        end

        it "fills out amounts from the calculator if method is standard" do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_deduction_method).and_return "S"
          expect(xml.at("Form502 NetIncome").text).to eq "40"
          expect(xml.at("Form502 ExemptionAmount").text).to eq "50"
          expect(xml.at("Form502 StateTaxComputation TaxableNetIncome").text).to eq "60"
          expect(xml.at("Form502 StateTaxComputation StateIncomeTax").text).to eq "70"
        end

        it "leaves amounts blank if method is not standard" do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_deduction_method).and_return "N"
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_21).and_return nil
          expect(xml.at("Form502 NetIncome")).to be_nil
          expect(xml.at("Form502 ExemptionAmount")).to be_nil
          expect(xml.at("Form502 StateTaxComputation TaxableNetIncome")).to be_nil
          expect(xml.at("Form502 StateTaxComputation StateIncomeTax")).to be_nil
        end
      end

      context "additions section" do
        before do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_3).and_return 40
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_6).and_return 50
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_7).and_return 60
        end

        it "fills out" do
          expect(xml.at("Form502 Additions StateRetirementPickup")&.text).to eq "40"
          expect(xml.at("Form502 Additions Total")&.text).to eq "50"
          expect(xml.at("Form502 Additions FedAGIAndStateAdditions")&.text).to eq "60"
        end
      end

      context "EIC section" do
        context "when qualifies for EIC" do
          before do
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_22).and_return 100
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_22b).and_return "X"
          end
          let(:intake) { create(:state_file_md_intake, :with_spouse) }
          it "fills in EIC fields" do
            expect(xml.at("Form502 StateTaxComputation")).to be_present
            expect(xml.at("Form502 StateTaxComputation EarnedIncomeCredit").text).to eq("100")
            expect(xml.at("Form502 StateTaxComputation MDEICWithQualChildInd").text).to eq("X")
          end
        end

        context "when they qualify for state EIC but don't have qualifying children" do
          before do
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_22).and_return 100
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_22b).and_return nil
          end
          let(:intake) { create(:state_file_md_intake, :with_spouse) }
          it "fills out EarnedIncomeCredit but not MDEICWithQualChildInd" do
            expect(xml.at("Form502 StateTaxComputation")).to be_present
            expect(xml.at("Form502 StateTaxComputation EarnedIncomeCredit").text).to eq("100")
            expect(xml.at("Form502 StateTaxComputation MDEICWithQualChildInd")).not_to be_present
          end
        end

        context "when they don't qualify for state EIC and don't have qualifying children" do
          before do
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_20).and_return nil
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_22).and_return nil
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_22b).and_return nil
          end
          let(:intake) { create(:state_file_md_intake, :with_spouse) }
          it "fills doesn't fill out the state tax computation section" do
            expect(xml.at("Form502 StateTaxComputation")).not_to be_present
            expect(xml.at("Form502 StateTaxComputation EarnedIncomeCredit")).not_to be_present
            expect(xml.at("Form502 StateTaxComputation MDEICWithQualChildInd")).not_to be_present
          end
        end
      end
    end

    context "Line 40: Total state and local tax withheld" do
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_40).and_return 500
      end

      it 'outputs the total state and local tax withheld' do
        expect(xml.at("Form502 TaxWithheld")&.text).to eq('500')
      end
    end
  end
end
