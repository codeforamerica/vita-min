require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Nj::Documents::Nj1040, required_schema: "nj" do
  describe ".document" do
    let(:intake) { create(:state_file_nj_intake, filing_status: "single", municipality_code: "0101") }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    it "includes municipality code with a prepending 0" do
      xml = described_class.build(submission).document
      expect(xml.document.at("CountyCode").to_s).to include("00101")
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

      context "when filer is blind" do
        let(:intake) { create(:state_file_nj_intake, :primary_blind) }
        it "populates line 8 XML fields" do
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
      context "when no w2 wages (line 15 is -1)" do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }

        it "does not include WagesSalariesTips item" do
          expect(xml.at("WagesSalariesTips")).to eq(nil)
        end
      end

      context "when w2 wages exist" do
        let(:intake) { create(:state_file_nj_intake, :df_data_many_w2s) }

        it "includes the sum in WagesSalariesTips item" do
          expected_sum = 50000 + 50000 + 50000 + 50000
          expect(xml.at("WagesSalariesTips").text).to eq(expected_sum.to_s)
        end
      end
    end

    describe "total exemption - lines 13 and 30" do
      let(:intake) { create(:state_file_nj_intake) }
      it "totals lines 6-8 and stores the result in both TotalExemptionAmountA and TotalExemptionAmountB" do
        line_6_single_filer = 1_000
        line_7_not_over_65 = 0
        line_8_not_blind = 0
        expected_sum = line_6_single_filer + line_7_not_over_65 + line_8_not_blind
        expect(xml.at("Exemptions TotalExemptionAmountA").text).to eq(expected_sum.to_s)
        expect(xml.at("Body TotalExemptionAmountB").text).to eq(expected_sum.to_s)
      end
    end

    describe "total income - line 27" do
      context "when filer submits w2 wages" do
        let(:intake) { create(:state_file_nj_intake, :df_data_many_w2s) }
        it "fills TotalIncome with the value from Line 15" do
          expected_line_15_w2_wages = 200_000
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
        let(:intake) { create(:state_file_nj_intake, :df_data_many_w2s) }
        it "fills TotalIncome with the value from Line 15" do
          expected_line_15_w2_wages = 200_000
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

    describe "total exemptions and deductions - line 38" do
      let(:intake) { create(:state_file_nj_intake) }
      it "fills TotalExemptDeductions with total exemptions and deductions" do
        line_6_single_filer = 1_000
        line_7_not_over_65 = 0
        line_8_not_blind = 0
        expected_sum = line_6_single_filer + line_7_not_over_65 + line_8_not_blind
        expect(xml.at("TotalExemptDeductions").text).to eq(expected_sum.to_s)
      end
    end

    describe "taxable income - line 39" do
      let(:intake) { create(:state_file_nj_intake, :df_data_many_w2s) }
      it "fills TaxableIncome with gross income minus total exemptions/deductions" do
        expected_line_15_w2_wages = 200_000
        line_6_single_filer = 1_000
        line_7_not_over_65 = 0
        line_8_not_blind = 0
        expected_total = expected_line_15_w2_wages - (line_6_single_filer + line_7_not_over_65 + line_8_not_blind)
        expect(xml.at("TaxableIncome").text).to eq(expected_total.to_s)
      end
    end

    describe "property tax - lines 40a and 40b" do
      context "when taxpayer is a renter" do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal, household_rent_own: 'rent', rent_paid: 54321) }

        it "adds a checked tenant element to property tax deduct or credit" do
          expect(xml.at("PropertyTaxDeductOrCredit Tenant").text).to eq("X")
          expect(xml.at("PropertyTaxDeductOrCredit Homeowner")).to eq(nil)
        end

        it "inserts property tax rent calculation on line 40a" do
          expect(xml.at("PropertyTaxDeductOrCredit TotalPropertyTaxPaid").text).to eq("9778")
        end
      end

      context "when taxpayer is a homeowner" do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal, household_rent_own: 'own', property_tax_paid: 12345) }

        it "adds a checked homeowner element to property tax deduct or credit" do
          expect(xml.at("PropertyTaxDeductOrCredit Homeowner").text).to eq("X")
          expect(xml.at("PropertyTaxDeductOrCredit Tenant")).to eq(nil)
        end

        it 'inserts property tax calculation on line 40a' do
          expect(xml.at("PropertyTaxDeductOrCredit TotalPropertyTaxPaid").text).to eq("12345")
        end
      end

      context "when taxpayer is a neither a homeowner nor a renter" do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal, household_rent_own: 'neither',) }

        it "does not add a checked tenant or homeowner element to property tax deduct or credit" do
          expect(xml.at("PropertyTaxDeductOrCredit Tenant")).to eq(nil)
          expect(xml.at("PropertyTaxDeductOrCredit Homeowner")).to eq(nil)
        end

        it 'does not add property tax on line 40a' do
          expect(xml.at("PropertyTaxDeductOrCredit TotalPropertyTaxPaid")).to eq(nil)
        end
      end
    end

    describe "new jersey taxable income - line 42" do
      let(:intake) { create(:state_file_nj_intake, :df_data_many_w2s) }
      it "fills NewJerseyTaxableIncome with taxable income" do
        expected_line_15_w2_wages = 200_000
        line_6_single_filer = 1_000
        line_7_not_over_65 = 0
        line_8_not_blind = 0
        expected_total = expected_line_15_w2_wages - (line_6_single_filer + line_7_not_over_65 + line_8_not_blind)
        expect(xml.at("NewJerseyTaxableIncome").text).to eq(expected_total.to_s)
      end
    end
    
    describe "child and dependent care credit - line 64" do
      let(:intake) { create(:state_file_nj_intake, :df_data_one_dep, :fed_credit_for_child_and_dependent_care) }
      it "adds 40% of federal credit for an income of 60k or less" do
        expect(xml.at("ChildDependentCareCredit").text).to eq('400.0')
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
        let(:intake) { create(:state_file_nj_intake, :df_data_one_dep) }
        it 'returns 600 for incomes less than or equal to 50k' do
          intake.synchronize_df_dependents_to_database
          five_years = Date.new(MultiTenantService.new(:statefile).current_tax_year - 5, 1, 1)
          intake.dependents.first.update(dob: five_years)
          intake.dependents.reload
          expect(xml.at("Body NJChildTCNumOfDep").text).to eq(1.to_s)
          expect(xml.at("Body NJChildTaxCredit").text).to eq(600.to_s)
        end
      end
    end
  end
end