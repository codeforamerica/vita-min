require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Nj::Documents::Nj1040, required_schema: "nj" do
  describe ".document" do
    let(:intake) { create(:state_file_nj_intake, filing_status: "single") }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: true) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    after do
      expect(build_response.errors).not_to be_present
    end

    context "with municipality code" do
      let(:intake) { create(:state_file_nj_intake, municipality_code: "0304") }

      it "includes municipality code with a prepending 0" do
        xml = described_class.build(submission).document
        expect(xml.document.at("CountyCode").to_s).to include("00304")
      end
    end

    context "when filer has no spouse" do
      it "only adds single filing status child xml element" do
        expect(xml.document.at('FilingStatus').elements.length).to eq 1
        expect(xml.document.at('FilingStatus').elements[0].name).to eq "Single"
      end

      it "indicates single filing status with an X" do
        expect(xml.document.at('FilingStatus Single').text).to eq "X"
      end

      it "Exemptions are populated" do
        expect(xml.css('Exemptions').count).to eq(1)
      end

      it "populates line 6 XML fields" do
        expect(xml.at("Exemptions YouRegular").text).to eq("X")
        expect(xml.at("Exemptions SpouseCuRegular")).to eq(nil)
        expect(xml.at("Exemptions DomesticPartnerRegular")).to eq(nil)
      end

      it "populates line 8 XML fields" do
        expect(xml.at("Exemptions YouBlindOrDisabled")).to eq(nil)
        expect(xml.at("Exemptions SpouseCuPartnerBlindOrDisabled")).to eq(nil)
      end

      it "populates line 9 XML fields" do
        expect(xml.at("Exemptions YouVeteran")).to eq(nil)
        expect(xml.at("Exemptions SpouseCuPartnerVeteran")).to eq(nil)
      end

      context "when filer is blind" do
        let(:intake) { create(:state_file_nj_intake, :primary_blind) }
        it "populates line 8 XML fields" do
          expect(xml.at("Exemptions YouBlindOrDisabled").text).to eq("X")
          expect(xml.at("Exemptions SpouseCuPartnerBlindOrDisabled")).to eq(nil)
        end
      end

      context "when filer is disabled" do
        let(:intake) { create(:state_file_nj_intake, :primary_disabled) }
        it "claims the YouBlindOrDisabled exemption" do
          expect(xml.at("Exemptions YouBlindOrDisabled").text).to eq("X")
          expect(xml.at("Exemptions SpouseCuPartnerBlindOrDisabled")).to eq(nil)
        end
      end

      context "when filer is over 65" do
        let(:intake) { create(:state_file_nj_intake, :primary_over_65) }
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65").text).to eq("X")
          expect(xml.at("Exemptions SpouseCuPartner65OrOver")).to eq(nil)
        end
      end

      context "when filer is younger than 65" do
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65")).to eq(nil)
          expect(xml.at("Exemptions SpouseCuPartner65OrOver")).to eq(nil)
        end
      end

      context "when filer is a veteran" do
        let(:intake) { create(:state_file_nj_intake, :primary_veteran) }
        it "sets YouVeteran XML to true" do
          expect(xml.at("Exemptions YouVeteran").text).to eq("X")
          expect(xml.at("Exemptions SpouseCuPartnerVeteran")).to eq(nil)
        end
      end
    end

    context "when filer is married filing jointly" do
      let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
      it "Exemptions are populated" do
        expect(xml.css('Exemptions').count).to eq(1)
      end

      it "populates line 6 XML fields" do
        expect(xml.at("Exemptions YouRegular").text).to eq("X")
        expect(xml.at("Exemptions SpouseCuRegular").text).to eq("X")
        expect(xml.at("Exemptions DomesticPartnerRegular")).to eq(nil)
      end

      context "when filer is over 65 and spouse is under 65" do
        let(:intake) { create(:state_file_nj_intake, :primary_over_65, :married_filing_jointly) }
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65").text).to eq("X")
          expect(xml.at("Exemptions SpouseCuPartner65OrOver")).to eq(nil)
        end
      end

      context "when filer is over 65 and spouse is over 65" do
        let(:intake) { create(:state_file_nj_intake, :primary_over_65, :mfj_spouse_over_65) }
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65").text).to eq("X")
          expect(xml.at("Exemptions SpouseCuPartner65OrOver").text).to eq("X")
        end
      end

      context "when filer is under 65 and spouse is under 65" do
        let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65")).to eq(nil)
          expect(xml.at("Exemptions SpouseCuPartner65OrOver")).to eq(nil)
        end
      end

      context "when filer is under 65 and spouse is over 65" do
        let(:intake) { create(:state_file_nj_intake, :mfj_spouse_over_65) }
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65")).to eq(nil)
          expect(xml.at("Exemptions SpouseCuPartner65OrOver").text).to eq("X")
        end
      end

      context "when filer is blind and their spouse is not blind" do
        let(:intake) { create(:state_file_nj_intake, :primary_blind) }
        it "populates line 8 XML fields" do
          expect(xml.at("Exemptions YouBlindOrDisabled").text).to eq("X")
          expect(xml.at("Exemptions SpouseCuPartnerBlindOrDisabled")).to eq(nil)
        end
      end

      context "when filer is not blind and their spouse is blind" do
        let(:intake) { create(:state_file_nj_intake, :spouse_blind) }
        it "populates line 8 XML fields" do
          expect(xml.at("Exemptions YouBlindOrDisabled")).to eq(nil)
          expect(xml.at("Exemptions SpouseCuPartnerBlindOrDisabled").text).to eq("X")
        end
      end

      context "when filer and their spouse are both blind" do
        let(:intake) { create(:state_file_nj_intake, :primary_blind, :spouse_blind) }
        it "populates line 8 XML fields" do
          expect(xml.at("Exemptions YouBlindOrDisabled").text).to eq("X")
          expect(xml.at("Exemptions SpouseCuPartnerBlindOrDisabled").text).to eq("X")
        end
      end

      context "when both filer and their spouse are disabled" do
        let(:intake) { create(:state_file_nj_intake, :primary_disabled, :spouse_disabled) }
        it "claims the YouBlindOrDisabled and the SpouseCuPartnerBlindOrDisabled exemptions" do
          expect(xml.at("Exemptions YouBlindOrDisabled").text).to eq("X")
          expect(xml.at("Exemptions SpouseCuPartnerBlindOrDisabled").text).to eq("X")
        end
      end
      
      context "when filer and their spouse are both veterans" do
        let(:intake) { create(:state_file_nj_intake, :primary_veteran, :spouse_veteran) }
        it "checks both line 9 XML fields" do
          expect(xml.at("Exemptions YouVeteran").text).to eq("X")
          expect(xml.at("Exemptions SpouseCuPartnerVeteran").text).to eq("X")
        end
      end

      it "only adds married filing jointly filing status child xml element" do
        expect(xml.document.at('FilingStatus').elements.length).to eq 1
        expect(xml.document.at('FilingStatus').elements[0].name).to eq "MarriedCuPartFilingJoint"
      end
      
      it "indicates married filing jointly status with an X" do
        expect(xml.document.at('FilingStatus MarriedCuPartFilingJoint').text).to eq "X"
      end
    end

    context "married filing separately filers" do
      let(:intake) { create(:state_file_nj_intake, :married_filing_separately) }

      it "only adds married filing separately filing status child xml element" do
        expect(xml.document.at('FilingStatus').elements.length).to eq 1
        expect(xml.document.at('FilingStatus').elements[0].name).to eq "MarriedCuPartFilingSeparate"
      end
      
      it "fills married filing separately status spouse fields for ssn and name" do
        expect(xml.document.at('FilingStatus MarriedCuPartFilingSeparate SpouseSSN').text).to eq(intake.spouse.ssn)
        expect(xml.document.at('FilingStatus MarriedCuPartFilingSeparate SpouseName FirstName').text).to eq(intake.spouse.first_name)
        expect(xml.document.at('FilingStatus MarriedCuPartFilingSeparate SpouseName MiddleInitial').text).to eq(intake.spouse.middle_initial)
        expect(xml.document.at('FilingStatus MarriedCuPartFilingSeparate SpouseName LastName').text).to eq(intake.spouse.last_name)
      end
    end

    context "qualifying widow/er filers" do
      let(:intake) { create(:state_file_nj_intake, filing_status: "qualifying_widow") }
      
      context "when spouse passed last year" do
        before do
          date_within_prior_year = "#{MultiTenantService.new(:statefile).current_tax_year}-09-30"
          submission.data_source.direct_file_data.spouse_date_of_death = date_within_prior_year
        end
  
        it "only adds the qualifying widow/er filing status child xml element" do
          expect(xml.document.at('FilingStatus').elements.length).to eq 1
          expect(xml.document.at('FilingStatus').elements[0].name).to eq "QualWidOrWider"
        end

        it "indicates filing status with an X and indicates that spouse passed last tax year" do
          expect(xml.document.at('FilingStatus QualWidOrWider QualWidOrWiderSurvCuPartner').text).to eq "X"
          expect(xml.document.at('FilingStatus QualWidOrWider LastYear').text).to eq "X"
          expect(xml.document.at('FilingStatus QualWidOrWider').elements.length).to eq 2
        end
      end

      context "when spouse passed two years prior" do
        before do
          date_within_prior_year = "#{MultiTenantService.new(:statefile).current_tax_year - 1}-09-30"
          submission.data_source.direct_file_data.spouse_date_of_death = date_within_prior_year
        end
  
        it "only adds the qualifying widow/er filing status child xml element" do
          expect(xml.document.at('FilingStatus').elements.length).to eq 1
          expect(xml.document.at('FilingStatus').elements[0].name).to eq "QualWidOrWider"
        end

        it "indicates filing status with an X and indicates that spouse passed last tax year" do
          expect(xml.document.at('FilingStatus QualWidOrWider QualWidOrWiderSurvCuPartner').text).to eq "X"
          expect(xml.document.at('FilingStatus QualWidOrWider TwoYearPrior').text).to eq "X"
          expect(xml.document.at('FilingStatus QualWidOrWider').elements.length).to eq 2
        end
      end
    end

    describe "qualified dependent children and other dependents" do
      context 'when 1 qualified child and 1 other dependent' do
        let(:intake) { create(:state_file_nj_intake, :df_data_two_deps) }
        it "sets NumOfQualiDependChild and NumOfOtherDepend to 1" do
          expect(xml.document.at('NumOfQualiDependChild').text).to eq "1"
          expect(xml.document.at('NumOfOtherDepend').text).to eq "1"
        end
      end
  
      context 'when 10 qualified children and 1 other dependent' do
        let(:intake) { create(:state_file_nj_intake, :df_data_many_deps) }
        it "sets NumOfQualiDependChild to 10 and NumOfOtherDepend to 1" do
          expect(xml.document.at('NumOfQualiDependChild').text).to eq "10"
          expect(xml.document.at('NumOfOtherDepend').text).to eq "1"
        end
      end
  
      context 'when 0 qualified child and 0 other dependent' do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }
        it "leaves NumOfQualiDependChild and NumOfOtherDepend blank" do
          expect(xml.document.at('NumOfQualiDependChild')).to eq nil
          expect(xml.document.at('NumOfOtherDepend')).to eq nil
        end
      end
    end

    describe 'dependents' do
      context 'when no dependents' do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }

        it 'does not include dependents section' do
          expect(xml.at("Dependents")).to eq(nil)
        end
      end

      context 'when many dependents' do
        let(:intake) { create(:state_file_nj_intake, :df_data_many_deps) }

        before do
          intake.dependents.each_with_index do |dependent, i|
            dependent.update(
              dob: i.years.ago(Date.new(2020, 1, 1)),
              first_name: "Firstname#{i}",
              last_name: "Lastname#{i}",
              middle_initial: 'ABCDEFGHIJK'[i],
              suffix: 'JR',
              ssn: "0000000#{"%02d" % i}"
            )
          end
        end

        it 'includes each dependent names, SSN, and year of birth to a maximum of 10' do
          expect(xml.css("Dependents").count).to eq(10)

          first_dep = xml.css("Dependents")[0]
          first_dep_name = first_dep.at("DependentsName")
          first_dep_ssn = first_dep.at("DependentsSSN")
          first_dep_birth_year = first_dep.at("BirthYear")
          expect(first_dep_name.at("FirstName").text).to eq("Firstname0")
          expect(first_dep_name.at("LastName").text).to eq("Lastname0")
          expect(first_dep_name.at("MiddleInitial").text).to eq("A")
          expect(first_dep_name.at("NameSuffix").text).to eq("JR")
          expect(first_dep_ssn.text).to eq("000000000")
          expect(first_dep_birth_year.text).to eq("2020")

          last_dep = xml.css("Dependents")[9]
          last_dep_name = last_dep.at("DependentsName")
          last_dep_ssn = last_dep.at("DependentsSSN")
          last_dep_birth_year = last_dep.at("BirthYear")
          expect(last_dep_name.at("FirstName").text).to eq("Firstname9")
          expect(last_dep_name.at("LastName").text).to eq("Lastname9")
          expect(last_dep_name.at("MiddleInitial").text).to eq("J")
          expect(last_dep_name.at("NameSuffix").text).to eq("JR")
          expect(last_dep_ssn.text).to eq("000000009")
          expect(last_dep_birth_year.text).to eq("2011")
        end
      end
    end

    describe "wages" do
      let(:intake) { create(:state_file_nj_intake) }

      context "when no w2 wages (line 15 is -1)" do
        it "does not include WagesSalariesTips item" do
          allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_15).and_return(-1)
          expect(xml.at("WagesSalariesTips")).to eq(nil)
        end
      end

      context "when w2 wages exist" do
        it "includes the sum in WagesSalariesTips item" do
          expected_sum = 50000 + 50000 + 50000 + 50000
          allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_15).and_return expected_sum
          expect(xml.at("WagesSalariesTips").text).to eq(expected_sum.to_s)
        end
      end
    end

    describe "dependents attending college - line 12" do
      context 'when has dependents in college' do
        let(:intake) { create(:state_file_nj_intake, :df_data_two_deps, :two_dependents_in_college) }
        it 'sets DependAttendCollege to count 2' do
          expect(xml.at("Exemptions DependAttendCollege").text).to eq("2")
        end
      end

      context 'when does not have dependents in college' do
        let(:intake) { create(:state_file_nj_intake, :df_data_two_deps) }
        it 'does not fill DependAttendCollege' do
          expect(xml.at("Exemptions DependAttendCollege")).to eq(nil)
        end
      end
    end

    describe "total exemption - lines 13 and 30" do
      let(:intake) { create(:state_file_nj_intake, :primary_over_65, :primary_blind, :primary_veteran, :two_dependents_in_college) }
      it "totals lines 6-12 and stores the result in both TotalExemptionAmountA and TotalExemptionAmountB" do
        line_6_single_filer = 1_000
        line_7_over_65 = 1_000
        line_8_blind = 1_000
        line_9_veteran = 6_000
        line_10_qualified_children = 1_500
        line_11_other_dependents = 1_500
        line_12_dependents_attending_college = 2_000
        expected_sum =
          line_6_single_filer +
          line_7_over_65 +
          line_8_blind +
          line_9_veteran +
          line_10_qualified_children +
          line_11_other_dependents +
          line_12_dependents_attending_college
        expect(xml.at("Exemptions TotalExemptionAmountA").text).to eq(expected_sum.to_s)
        expect(xml.at("Body TotalExemptionAmountB").text).to eq(expected_sum.to_s)
      end
    end

    describe 'line 16a taxable interest income' do
      context 'with no interest reports' do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }
        it 'does not set line 16a' do
          expect(xml.at("Body TaxableInterestIncome")).to eq(nil)
        end
      end
  
      context 'with interest reports, but no interest on government bonds' do
        let(:intake) { create(:state_file_nj_intake, :df_data_one_dep) }
        it 'does not set line 16a' do
          expect(xml.at("Body TaxableInterestIncome")).to eq(nil)
        end
      end 
  
      context 'with interest on government bonds' do
        let(:intake) { create(:state_file_nj_intake, :df_data_two_deps) }
        it 'sets line 16a to 300 (fed taxable income minus sum of bond interest)' do
          expect(xml.at("Body TaxableInterestIncome").text).to eq("300")
        end
      end
    end

    describe 'line 16b tax exempt interest income' do
      context 'with no tax exempt interest income' do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }
        it 'does not set line 16b' do
          expect(xml.at("Body TaxexemptInterestIncome")).to eq(nil)
        end
      end
  
      context 'with tax exempt interest income and interest on government bonds less than 10k' do
        let(:intake) { create(:state_file_nj_intake, :df_data_two_deps) }
        it 'sets line 16b to the sum' do
          expect(xml.at("Body TaxexemptInterestIncome").text).to eq('201')
        end
      end
    end

    describe "total income - line 27" do
      context "when filer submits w2 wages" do
        it "fills TotalIncome with the value from Line 15" do
          expected_line_15_w2_wages = 200_000
          allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_15).and_return expected_line_15_w2_wages
          expect(xml.at("WagesSalariesTips").text).to eq(expected_line_15_w2_wages.to_s)
          expect(xml.at("TotalIncome").text).to eq(expected_line_15_w2_wages.to_s)
        end
      end

      context "when filer does not submit w2 wages" do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }
        it "does not include TotalIncome in the XML" do
          expect(xml.at("TotalIncome")).to eq(nil)
        end
      end
    end

    describe "gross income - line 29" do
      context "when filer submits w2 wages" do
        it "fills TotalIncome with the value from Line 15" do
          expected_line_15_w2_wages = 200_000
          allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_15).and_return expected_line_15_w2_wages
          expect(xml.at("WagesSalariesTips").text).to eq(expected_line_15_w2_wages.to_s)
          expect(xml.at("GrossIncome").text).to eq(expected_line_15_w2_wages.to_s)
        end
      end

      context "when filer does not submit w2 wages" do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }
        it "does not include TotalIncome in the XML" do
          expect(xml.at("GrossIncome")).to eq(nil)
        end
      end
    end

    describe "line 31 medical expenses" do
      context "with an income of 200k" do
        let(:intake) { create(:state_file_nj_intake, :df_data_many_w2s, medical_expenses: 10_000) }
        it "fills MedicalExpenses with medical expenses exceeding two percent gross income" do
          expected_line_15_w2_wages = 200_000
          two_percent_gross = expected_line_15_w2_wages * 0.02
          expected_value = 10_000 - two_percent_gross
          expect(xml.at("MedicalExpenses").text).to eq(expected_value.round.to_s)
        end
      end

      context "with no income" do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal, medical_expenses: 10_000) }
        it "fills MedicalExpenses with full medical expenses amount" do
          expected_value = 10_000
          expect(xml.at("MedicalExpenses").text).to eq(expected_value.round.to_s)
        end
      end

      context "with no medical expenses" do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal, medical_expenses: 0) }
        it "does not fill MedicalExpenses" do
          expect(xml.at("MedicalExpenses")).to eq(nil)
        end
      end
    end

    describe "total exemptions and deductions - line 38" do
      let(:intake) { create(:state_file_nj_intake, :df_data_many_deps, :primary_over_65, :primary_blind, :primary_veteran) }
      it "fills TotalExemptDeductions with total exemptions and deductions" do
        line_6_single_filer = 1_000
        line_7_over_65 = 1_000
        line_8_blind = 1_000
        line_9_veteran = 6_000
        line_10_qualified_children = 15_000
        line_11_other_dependents = 1_500
        expected_sum =
          line_6_single_filer +
          line_7_over_65 +
          line_8_blind +
          line_9_veteran +
          line_10_qualified_children +
          line_11_other_dependents
        expect(xml.at("TotalExemptDeductions").text).to eq(expected_sum.to_s)
      end
    end

    describe "taxable income - line 39" do
      it "fills TaxableIncome with gross income minus total exemptions/deductions" do
        expected_line_15_w2_wages = 200_000
        line_6_single_filer = 1_000
        line_7_not_over_65 = 0
        line_8_not_blind = 0
        line_9_not_veteran = 0
        line_10_qualified_children = 0
        line_11_other_dependents = 1_500
        exceptions =
          line_6_single_filer +
          line_7_not_over_65 +
          line_8_not_blind +
          line_9_not_veteran +
          line_10_qualified_children +
          line_11_other_dependents
        allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_15).and_return expected_line_15_w2_wages
        expected_total = expected_line_15_w2_wages - exceptions
        expect(xml.at("TaxableIncome").text).to eq(expected_total.to_s)
      end
    end

    describe "property tax - lines 40a and 40b" do
      context "when taxpayer is a renter with income above property tax minimum" do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :df_data_many_w2s, # income above minimum
            household_rent_own: 'rent',
            rent_paid: 54321
          )
        }

        it "adds a checked tenant element to property tax deduct or credit" do
          expect(xml.at("PropertyTaxDeductOrCredit Tenant").text).to eq("X")
          expect(xml.at("PropertyTaxDeductOrCredit Homeowner")).to eq(nil)
        end

        it "inserts property tax rent calculation on line 40a" do
          expect(xml.at("PropertyTaxDeductOrCredit TotalPropertyTaxPaid").text).to eq("9778")
        end
      end

      context "when taxpayer is a homeowner with income above property tax minimum" do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :df_data_many_w2s, # income above minimum
            household_rent_own: 'own',
            property_tax_paid: 12345
          )
        }

        it "adds a checked homeowner element to property tax deduct or credit" do
          expect(xml.at("PropertyTaxDeductOrCredit Homeowner").text).to eq("X")
          expect(xml.at("PropertyTaxDeductOrCredit Tenant")).to eq(nil)
        end

        it 'inserts property tax calculation on line 40a' do
          expect(xml.at("PropertyTaxDeductOrCredit TotalPropertyTaxPaid").text).to eq("12345")
        end
      end

      context "when taxpayer is a neither a homeowner nor a renter" do
        let(:intake) { create(:state_file_nj_intake, :df_data_many_w2s, household_rent_own: 'neither',) }

        it "does not add a checked tenant or homeowner element to property tax deduct or credit" do
          expect(xml.at("PropertyTaxDeductOrCredit Tenant")).to eq(nil)
          expect(xml.at("PropertyTaxDeductOrCredit Homeowner")).to eq(nil)
        end

        it 'does not add property tax on line 40a' do
          expect(xml.at("PropertyTaxDeductOrCredit TotalPropertyTaxPaid")).to eq(nil)
        end
      end

      context "when taxpayer does not have enough income to claim property tax credit or deduction" do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }

        it 'does not add property tax on line 40a' do
          expect(xml.at("PropertyTaxDeductOrCredit TotalPropertyTaxPaid")).to eq(nil)
        end
      end
    end

    describe "property tax deduction - line 41" do
      context 'when taking property tax deduction' do
        let(:intake) { 
          create(:state_file_nj_intake,
                              :df_data_many_w2s,
                              household_rent_own: 'own',
                              property_tax_paid: 15_000,
        )
        }

        it "fills PropertyTaxDeduction with property tax deduction amount" do
          allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_property_tax_deduction).and_return 15000
          allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:should_use_property_tax_deduction).and_return true
          expect(xml.at("PropertyTaxDeduction").text).to eq(15000.to_s)
        end
      end

      context 'when not taking property tax deduction' do
        let(:intake) { 
          create(:state_file_nj_intake,
                              :df_data_many_w2s,
                              household_rent_own: 'own',
                              property_tax_paid: 0,
                              )
        }

        it "leaves PropertyTaxDeduction empty" do
          expect(xml.at("PropertyTaxDeduction")).to eq(nil)
        end
      end

      context 'when not eligible for property tax deduction due to income' do
        let(:intake) {
          create(:state_file_nj_intake,
            :df_data_minimal, # income below minimum
            :primary_over_65,
            household_rent_own: 'rent',
            rent_paid: 54321
          )
        }

        it "leaves PropertyTaxDeduction empty" do
          expect(xml.at("PropertyTaxDeduction")).to eq(nil)
        end
      end
    end

    describe "new jersey taxable income - line 42" do
      it "fills NewJerseyTaxableIncome with taxable income" do
        expected_line_15_w2_wages = 200_000
        line_6_single_filer = 1_000
        line_7_not_over_65 = 0
        line_8_not_blind = 0
        line_9_not_veteran = 0
        line_10_qualified_children = 0
        line_11_other_dependents = 1_500
        exceptions =
          line_6_single_filer +
          line_7_not_over_65 +
          line_8_not_blind +
          line_9_not_veteran +
          line_10_qualified_children +
          line_11_other_dependents
        expected_total = expected_line_15_w2_wages - exceptions
        allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_15).and_return expected_line_15_w2_wages
        expect(xml.at("NewJerseyTaxableIncome").text).to eq(expected_total.to_s)
      end
    end

    describe "tax amount - line 43" do
      let(:intake) { 
        create(:state_file_nj_intake,
                            :df_data_many_w2s,
                            :married_filing_jointly,
                            household_rent_own: 'own',
                            property_tax_paid: 15_000,
                            )
      }

      it "fills Tax with rounded tax amount based on tax rate and line 42" do
        expected = 7_615 # (200,000 - 2,000 - 15,000) * 0.0637 - 4,042 rounded
        allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_43).and_return expected
        expect(xml.at("Tax").text).to eq(expected.to_s)
      end
    end

    describe "use tax - line 51" do
      let(:intake) { create(:state_file_nj_intake, sales_use_tax: 123) }
      it "fills SalesAndUseTax with sales_use_tax" do
        expect(xml.at("SalesAndUseTax").text).to eq(123.to_s)
      end
    end

    describe "property tax credit - line 56" do
      context 'when no property tax paid' do
        let(:intake) { 
          create(:state_file_nj_intake,
                              :df_data_many_w2s,
                              household_rent_own: 'own',
                              property_tax_paid: 0,
                              )
        }

        it "fills with $50 tax credit" do
          expect(xml.at("PropertyTaxCredit").text).to eq(50.to_s)
        end
      end

      context 'when not eligible for property tax deduction or credit due to income' do
        let(:intake) {
          create(:state_file_nj_intake,
            :df_data_minimal,
            household_rent_own: 'rent',
            rent_paid: 54321
          )
        }

        it "is empty" do
          expect(xml.at("PropertyTaxCredit")).to eq(nil)
        end
      end

      context 'when not eligible for property tax deduction due to income but eligible for credit' do
        let(:intake) {
          create(:state_file_nj_intake,
            :df_data_minimal,
            :primary_over_65,
            household_rent_own: 'rent',
            rent_paid: 54321
          )
        }

        it "fills with $50 tax credit" do
          expect(xml.at("PropertyTaxCredit").text).to eq(50.to_s)
        end
      end
    end

    describe "estimated tax payments - line 57" do
      context 'when estimated_tax_payments has a value' do
        let(:intake) { create(:state_file_nj_intake, estimated_tax_payments: 596) }

        it "fills EstimatedPaymentTotal with estimated_tax_payments" do
          expect(xml.at("EstimatedPaymentTotal").text).to eq(596.to_s)
        end
      end

      context 'when estimated_tax_payments is nil' do
        let(:intake) { create(:state_file_nj_intake) }

        it "does not fill EstimatedPaymentTotal" do
          expect(xml.at("EstimatedPaymentTotal")).to eq(nil)
        end
      end
    end

    describe "earned income tax credit - line 58" do
      context 'when there is EarnedIncomeCreditAmt on the federal 1040' do
        before do
          allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_58).and_return 596
          allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_58_irs).and_return true
        end

        it "fills EarnedIncomeCreditAmount with $596 for 40% of federal tax credit and checks EICFederalAmt" do
          expect(xml.at("EarnedIncomeCredit EarnedIncomeCreditAmount").text).to eq(596.to_s)
          expect(xml.at("EarnedIncomeCredit EICFederalAmt").text).to eq('X')
        end
      end

      context 'when there is no EarnedIncomeCreditAmt on the federal 1040' do
        context 'when taxpayer is eligible for NJ EITC' do
          before do
            allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_58).and_return 240
            allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_58_irs).and_return false
          end

          it "fills EarnedIncomeCreditAmount with flat $240 and does not check EICFederalAmt" do
            expect(xml.at("EarnedIncomeCredit EarnedIncomeCreditAmount").text).to eq(240.to_s)
            expect(xml.at("EarnedIncomeCredit EICFederalAmt")).to eq(nil)
          end
        end

        context 'when taxpayer is not eligible for NJ EITC' do
          before do
            allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_58).and_return 0
            allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_58_irs).and_return false
          end

          it "does not fill EarnedIncomeCreditAmount and does not check EICFederalAmt" do
            expect(xml.at("EarnedIncomeCredit")).to eq(nil)
            expect(xml.at("EarnedIncomeCredit EarnedIncomeCreditAmount")).to eq(nil)
            expect(xml.at("EarnedIncomeCredit EICFederalAmt")).to eq(nil)
          end
        end
      end
    end

    describe "line 59 - excess UI/WF/SWF or UI/HC/WD" do
      context "mfj with multiple w2s per spouse that individually do not exceed the max and total more than the max for each spouse" do 
        before do
          allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_59).and_return 123
        end
        it 'adds the sum to line 59' do
          expect(xml.at("ExcessNjUiWfSwf").text).to eq('123')
        end
      end
    end

    describe "line 61 - excess FLI" do
      context "mfj with multiple w2s per spouse that individually do not exceed max and total more than max for each spouse" do 
        before do
          allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_61).and_return 123
        end
        it 'adds the sum to line 61' do
          expect(xml.at("ExcesNjFamiInsur").text).to eq('123')
        end
      end
    end

    describe "child and dependent care credit - line 64" do
      it "adds 40% of federal credit for an income of 60k or less" do
        allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_64).and_return 400
        expect(xml.at("ChildDependentCareCredit").text).to eq('400')
      end
    end

    describe "NJ child tax credit - line 65" do
      context "when taxpayer is not eligible" do
        let(:intake) { create(:state_file_nj_intake, :married_filing_separately) }
        it 'returns nil' do
          expect(xml.at("Body NJChildTCNumOfDep")).to eq(nil)
          expect(xml.at("Body NJChildTaxCredit")).to eq(nil)
        end
      end

      context "when taxpayer is eligible" do
        it 'returns 600 for incomes less than or equal to 50k' do
          intake.synchronize_df_dependents_to_database
          five_years = Date.new(MultiTenantService.new(:statefile).current_tax_year - 5, 1, 1)
          intake.dependents.first.update(dob: five_years)
          intake.dependents.reload
          allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_65).and_return 600
          expect(xml.at("Body NJChildTCNumOfDep").text).to eq(1.to_s)
          expect(xml.at("Body NJChildTaxCredit").text).to eq(600.to_s)
        end
      end
    end
  end
end