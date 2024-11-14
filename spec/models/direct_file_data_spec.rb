require 'rails_helper'

describe DirectFileData do
  let(:xml) { Nokogiri::XML(StateFile::DirectFileApiResponseSampleService.new.read_xml("az_df_complete_sample")) }
  let(:direct_file_data) { DirectFileData.new(xml.to_s) }

  [
    ["tax_return_year", 2023],
    ["filing_status", 4],
    ["phone_number", "4805555555"],
    ["cell_phone_number", "5551231234"],
    ["tax_payer_email", "test011@test.com"],
    ["primary_ssn", "400000003"],
    ["spouse_ssn", "500000003"],
    ["primary_occupation", "Singer"],
    ["spouse_occupation", "Actor"],
    ["surviving_spouse", "X"],
    ["spouse_date_of_death", "2024-07-06"],
    ["spouse_name", "Allen"],
    ["mailing_city", "Phoenix"],
    ["mailing_street", "321 Roland St"],
    ["mailing_apartment", "Apt B"],
    ["mailing_state", "AZ"],
    ["mailing_zip", "85034"],
    ["fed_tax_amt", 1993],
    ["fed_calculated_difference_amount", 1634],
    ["fed_nontaxable_combat_pay_amount", 10],
    ["fed_total_earned_income_amount", 35000],
    ["fed_puerto_rico_income_exclusion_amount", 80],
    ["fed_total_income_exclusion_amount", 600],
    ["fed_housing_deduction_amount", 700],
    ["fed_gross_income_exclusion_amount", 900],
    ["qualifying_children_under_age_ssn_count", "1"],
    ["primary_over_65", "X"],
    ["spouse_over_65", "X"],
    ["primary_blind", "X"],
    ["spouse_blind", "X"],
  ].each do |node_name, current_value|
    describe "##{node_name}" do
      it "returns the value" do
        expect(direct_file_data.send(node_name)).to eq current_value
      end

      if current_value.is_a?(Integer) && !node_name.ends_with?("_year", "_status")
        context "when the attribute is an amount and is not present" do
          before do
            selector = DirectFileData::SELECTORS[node_name.to_sym]
            xml.at(selector).remove
          end

          it "defaults to 0" do
            expect(direct_file_data.send(node_name)).to eq 0
          end
        end
      end
    end

    describe "##{node_name}=" do
      it "can write a value" do
        # test with something that can be converted .to_i for the amount fields
        direct_file_data.send("#{node_name}=", "123")
        expect(direct_file_data.send(node_name).to_s).to eq "123"
      end
    end
  end

  describe "#is_primary_blind?" do
    it "returns true when value is X" do
      expect(direct_file_data.is_primary_blind?).to eq true
    end

    it "returns false when node absent" do
      xml.at('PrimaryBlindInd').remove
      expect(direct_file_data.is_primary_blind?).to eq false
    end
  end

  describe "#is_spouse_blind?" do
    it "returns true when value is X" do
      expect(direct_file_data.is_spouse_blind?).to eq true
    end

    it "returns false when node absent" do
      xml.at('SpouseBlindInd').remove
      expect(direct_file_data.is_spouse_blind?).to eq false
    end
  end

  describe "#phone_number=" do
    let(:xml) { Nokogiri::XML(StateFile::DirectFileApiResponseSampleService.new.old_xml_sample) }

    it "adds the node in the right place" do
      direct_file_data.phone_number = "5551231234"

      expect(direct_file_data.phone_number).to eq "5551231234"
    end
  end

  describe "#qualifying_children_under_age_ssn_count=" do
    it "writes to the value when the node is present" do
      direct_file_data.qualifying_children_under_age_ssn_count = 3

      expect(direct_file_data.qualifying_children_under_age_ssn_count).to eq "3"
    end
  end

  describe '#ny_public_employee_retirement_contributions' do
    let(:desc1) { '414H' }
    let(:desc2) { '414 (H)' }

    before do
      doc = Nokogiri::XML(StateFile::DirectFileApiResponseSampleService.new.old_xml_sample)
      # clone the single w2 so there are two of them
      doc.at('IRSW2').add_next_sibling(doc.at('IRSW2').to_s)
      doc.css('IRSW2')[1]['documentId'] = 'W20002'

      # update both w2s to have a box14 code in the list
      doc.css('IRSW2')[0].at('AllocatedTipsAmt').add_next_sibling(<<~XML)
        <OtherDeductionsBenefitsGrp>
          <Desc>#{desc1}</Desc>
          <Amt>123</Amt>
        </OtherDeductionsBenefitsGrp>
      XML
      doc.css('IRSW2')[1].at('AllocatedTipsAmt').add_next_sibling(<<~XML)
        <OtherDeductionsBenefitsGrp>
          <Desc>#{desc2}</Desc>
          <Amt>100</Amt>
        </OtherDeductionsBenefitsGrp>
      XML

      @direct_file_data = DirectFileData.new(doc.to_s)
    end

    it "sums up the box14 amounts for anything associated with public employee retirement" do
      expect(@direct_file_data.ny_public_employee_retirement_contributions).to eq(223)
    end

    context "when the desc provided is not an exact match (different casing)" do
      let(:desc1) { '414h' }

      it "still sums up the numbers" do
        expect(@direct_file_data.ny_public_employee_retirement_contributions).to eq(223)
      end
    end

    context 'when the desc provided is not an exact match (different format)' do
      let(:desc1) { '414 (H)' }

      it 'still sums up the numbers correctly when there are parens' do
        expect(@direct_file_data.ny_public_employee_retirement_contributions).to eq(223)
      end
    end

    context 'when the desc provided is not an exact match (multiple parens)' do
      let(:desc1) { '414 (H)(CU)' }

      it 'still sums up the numbers with spaces and parens' do
        expect(@direct_file_data.ny_public_employee_retirement_contributions).to eq(223)
      end
    end

    context 'when the desc provided is not an exact match but starts with 414H' do
      let(:desc1) { '414 H random' }

      it 'still sums up the numbers with spaces and starting 414H' do
        expect(@direct_file_data.ny_public_employee_retirement_contributions).to eq(223)
      end
    end

    context 'when the desc provided is not an exact match but starts with 414_H' do
      let(:desc1) { '414_H' }

      it 'still sums up the numbers with spaces and starting 414H' do
        expect(@direct_file_data.ny_public_employee_retirement_contributions).to eq(223)
      end
    end
  end

  describe '#fed_adjustments_claimed' do
    before do
      @doc = Nokogiri::XML(StateFile::DirectFileApiResponseSampleService.new.old_xml_sample)
    end

    context "when all known adjustment types are present" do
      before do
        @direct_file_data = DirectFileData.new(@doc.to_s)
      end

      it "generates a hash with all known types" do
        expect(@direct_file_data.fed_adjustments_claimed[:fed_educator_expenses][:amount]).to eq(300)
        expect(@direct_file_data.fed_adjustments_claimed[:fed_student_loan_interest][:amount]).to eq(2500)

        expect(@direct_file_data.fed_total_adjustments).to eq(2800)
      end
    end

    context "when not all known adjustment types are present" do
      before do
        @doc.at("IRS1040Schedule1 EducatorExpensesAmt").remove
        @doc.at("IRS1040Schedule1 TotalAdjustmentsAmt").content = "2500"
        @direct_file_data = DirectFileData.new(@doc.to_s)
      end

      it "generates a hash with only the types that were present" do
        expect(@direct_file_data.fed_adjustments_claimed).not_to have_key(:fed_educator_expenses)
        expect(@direct_file_data.fed_adjustments_claimed[:fed_student_loan_interest][:amount]).to eq(2500)

        expect(@direct_file_data.fed_total_adjustments).to eq(2500)
      end
    end

    context "when some adjustment types have an amount of 0" do
      before do
        @doc.at("IRS1040Schedule1 StudentLoanInterestDedAmt").content = "0"
        @doc.at("IRS1040Schedule1 TotalAdjustmentsAmt").content = "300"
        @direct_file_data = DirectFileData.new(@doc.to_s)
      end

      it "generates a hash with only the types that had positive values" do
        expect(@direct_file_data.fed_adjustments_claimed).not_to have_key(:fed_student_loan_interest)
        expect(@direct_file_data.fed_adjustments_claimed[:fed_educator_expenses][:amount]).to eq(300)

        expect(@direct_file_data.fed_total_adjustments).to eq(300)
      end
    end
  end

  describe '#fed_IRS1040Schedule1_fields' do
    before do
      @doc = Nokogiri::XML(StateFile::DirectFileApiResponseSampleService.new.old_xml_sample)
    end

    context "when all fields are present" do
      before do
        @doc.at("IRS1040Schedule1").add_child(Nokogiri::XML::Node.new('HousingDeductionAmt', @doc))
        @doc.at("IRS1040Schedule1 HousingDeductionAmt").content = "1000"
        @doc.at("IRS1040Schedule1").add_child(Nokogiri::XML::Node.new('GrossIncomeExclusionAmt', @doc))
        @doc.at("IRS1040Schedule1 GrossIncomeExclusionAmt").content = "2000"
        @doc.at("IRS1040Schedule1").add_child(Nokogiri::XML::Node.new('TotalIncomeExclusionAmt', @doc))
        @doc.at("IRS1040Schedule1 TotalIncomeExclusionAmt").content = "3000"
        @direct_file_data = DirectFileData.new(@doc.to_s)
      end

      it "sets the correct values" do
        expect(@direct_file_data.fed_unemployment).to eq(8500)
        expect(@direct_file_data.fed_housing_deduction_amount).to eq(1000)
        expect(@direct_file_data.fed_gross_income_exclusion_amount).to eq(2000)
        expect(@direct_file_data.fed_total_income_exclusion_amount).to eq(3000)
      end
    end

    context "when all fields are missing" do
      before do
        @doc.at("IRS1040Schedule1 UnemploymentCompAmt").remove
        @direct_file_data = DirectFileData.new(@doc.to_s)
      end

      it "sets the correct values" do
        expect(@direct_file_data.fed_unemployment).to eq 0
        expect(@direct_file_data.fed_housing_deduction_amount).to eq 0
        expect(@direct_file_data.fed_gross_income_exclusion_amount).to eq 0
        expect(@direct_file_data.fed_total_income_exclusion_amount).to eq 0
      end
    end
  end

  describe '#fed_IRS1040Schedule3_fields' do
    before do
      @doc = Nokogiri::XML(StateFile::DirectFileApiResponseSampleService.new.old_xml_sample)
    end

    context "when all fields are present" do
      before do
        @doc.at("ReturnData").add_child(Nokogiri::XML::Node.new('IRS1040Schedule3', @doc))
        @doc.at("IRS1040Schedule3").add_child(Nokogiri::XML::Node.new('ForeignTaxCreditAmt', @doc))
        @doc.at("IRS1040Schedule3 ForeignTaxCreditAmt").content = "100"
        @doc.at("IRS1040Schedule3").add_child(Nokogiri::XML::Node.new('CreditForChildAndDepdCareAmt', @doc))
        @doc.at("IRS1040Schedule3 CreditForChildAndDepdCareAmt").content = "200"
        @doc.at("IRS1040Schedule3").add_child(Nokogiri::XML::Node.new('EducationCreditAmt', @doc))
        @doc.at("IRS1040Schedule3 EducationCreditAmt").content = "300"
        @doc.at("IRS1040Schedule3").add_child(Nokogiri::XML::Node.new('RtrSavingsContributionsCrAmt', @doc))
        @doc.at("IRS1040Schedule3 RtrSavingsContributionsCrAmt").content = "400"
        @doc.at("IRS1040Schedule3").add_child(Nokogiri::XML::Node.new('EgyEffcntHmImprvCrAmt', @doc))
        @doc.at("IRS1040Schedule3 EgyEffcntHmImprvCrAmt").content = "500"
        @doc.at("IRS1040Schedule3").add_child(Nokogiri::XML::Node.new('CreditForElderlyOrDisabledAmt', @doc))
        @doc.at("IRS1040Schedule3 CreditForElderlyOrDisabledAmt").content = "600"
        @doc.at("IRS1040Schedule3").add_child(Nokogiri::XML::Node.new('CleanVehPrsnlUsePartCrAmt', @doc))
        @doc.at("IRS1040Schedule3 CleanVehPrsnlUsePartCrAmt").content = "700"
        @doc.at("IRS1040Schedule3").add_child(Nokogiri::XML::Node.new('TotRptgYrTxIncreaseDecreaseAmt', @doc))
        @doc.at("IRS1040Schedule3 TotRptgYrTxIncreaseDecreaseAmt").content = "800"
        @doc.at("IRS1040Schedule3").add_child(Nokogiri::XML::Node.new('MaxPrevOwnedCleanVehCrAmt', @doc))
        @doc.at("IRS1040Schedule3 MaxPrevOwnedCleanVehCrAmt").content = "900"
        @direct_file_data = DirectFileData.new(@doc.to_s)
      end

      it "sets the correct values" do
        expect(@direct_file_data.fed_foreign_tax_credit_amount).to eq(100)
        expect(@direct_file_data.fed_credit_for_child_and_dependent_care_amount).to eq(200)
        expect(@direct_file_data.fed_education_credit_amount).to eq(300)
        expect(@direct_file_data.fed_retirement_savings_contribution_credit_amount).to eq(400)
        expect(@direct_file_data.fed_energy_efficiency_home_improvement_credit_amount).to eq(500)
        expect(@direct_file_data.fed_credit_for_elderly_or_disabled_amount).to eq(600)
        expect(@direct_file_data.fed_clean_vehicle_personal_use_credit_amount).to eq(700)
        expect(@direct_file_data.fed_total_reporting_year_tax_increase_or_decrease_amount).to eq(800)
        expect(@direct_file_data.fed_previous_owned_clean_vehicle_credit_amount).to eq(900)
      end
    end

    context "when all fields are missing" do
      before do
        @direct_file_data = DirectFileData.new(@doc.to_s)
      end

      it "sets the correct values" do
        expect(@direct_file_data.fed_foreign_tax_credit_amount).to eq 0
        expect(@direct_file_data.fed_credit_for_child_and_dependent_care_amount).to eq 0
        expect(@direct_file_data.fed_education_credit_amount).to eq 0
        expect(@direct_file_data.fed_retirement_savings_contribution_credit_amount).to eq 0
        expect(@direct_file_data.fed_energy_efficiency_home_improvement_credit_amount).to eq 0
        expect(@direct_file_data.fed_credit_for_elderly_or_disabled_amount).to eq 0
        expect(@direct_file_data.fed_clean_vehicle_personal_use_credit_amount).to eq 0
        expect(@direct_file_data.fed_total_reporting_year_tax_increase_or_decrease_amount).to eq 0
        expect(@direct_file_data.fed_previous_owned_clean_vehicle_credit_amount).to eq 0
      end
    end
  end

  describe '#fed_IRS1040Schedule8812_fields' do
    before do
      @doc = Nokogiri::XML(StateFile::DirectFileApiResponseSampleService.new.old_xml_sample)
    end

    context "when all fields are present" do
      before do
        @doc.at("IRS1040Schedule8812 ClaimACTCAllFilersGrp").add_child(Nokogiri::XML::Node.new('CalculatedDifferenceAmt', @doc))
        @doc.at("IRS1040Schedule8812 ClaimACTCAllFilersGrp CalculatedDifferenceAmt").content = "1000"
        @doc.at("IRS1040Schedule8812 ClaimACTCAllFilersGrp").add_child(Nokogiri::XML::Node.new('NontaxableCombatPayAmt', @doc))
        @doc.at("IRS1040Schedule8812 ClaimACTCAllFilersGrp NontaxableCombatPayAmt").content = "2000"
        @direct_file_data = DirectFileData.new(@doc.to_s)
      end

      it "sets the correct values" do
        expect(@direct_file_data.fed_total_earned_income_amount).to eq(21000)
        expect(@direct_file_data.fed_calculated_difference_amount).to eq(1000)
        expect(@direct_file_data.fed_nontaxable_combat_pay_amount).to eq(2000)
      end
    end

    context "when all fields are missing" do
      before do
        @doc.at("IRS1040Schedule8812 ClaimACTCAllFilersGrp TotalEarnedIncomeAmt").remove
        @direct_file_data = DirectFileData.new(@doc.to_s)
      end

      it "sets the correct values" do
        expect(@direct_file_data.fed_total_earned_income_amount).to eq 0
        expect(@direct_file_data.fed_calculated_difference_amount).to eq 0
        expect(@direct_file_data.fed_nontaxable_combat_pay_amount).to eq 0
      end
    end
  end

  describe '#fed_OtherForm_fields' do
    before do
      @doc = Nokogiri::XML(StateFile::DirectFileApiResponseSampleService.new.old_xml_sample)
    end

    context "when all fields are present" do
      before do
        @doc.at("ReturnData").add_child(Nokogiri::XML::Node.new('IRS1040NR', @doc))
        @doc.at("IRS1040NR").add_child(Nokogiri::XML::Node.new('AmendedReturnInd', @doc))
        @doc.at("IRS1040NR AmendedReturnInd").content = "X"
        @doc.at("ReturnData").add_child(Nokogiri::XML::Node.new('IRS5695', @doc))
        @doc.at("IRS5695").add_child(Nokogiri::XML::Node.new('ResidentialCleanEnergyCrAmt', @doc))
        @doc.at("IRS5695 ResidentialCleanEnergyCrAmt").content = "1000"
        @doc.at("ReturnData").add_child(Nokogiri::XML::Node.new('IRS8396', @doc))
        @doc.at("IRS8396").add_child(Nokogiri::XML::Node.new('MortgageInterestCreditAmt', @doc))
        @doc.at("IRS8396 MortgageInterestCreditAmt").content = "2000"
        @doc.at("ReturnData").add_child(Nokogiri::XML::Node.new('IRS8839', @doc))
        @doc.at("IRS8839").add_child(Nokogiri::XML::Node.new('AdoptionCreditAmt', @doc))
        @doc.at("IRS8839 AdoptionCreditAmt").content = "3000"
        @doc.at("ReturnData").add_child(Nokogiri::XML::Node.new('IRS8859', @doc))
        @doc.at("IRS8859").add_child(Nokogiri::XML::Node.new('DCHmByrCurrentYearCreditAmt', @doc))
        @doc.at("IRS8859 DCHmByrCurrentYearCreditAmt").content = "4000"
        @doc.at("ReturnData").add_child(Nokogiri::XML::Node.new('IRS2441', @doc))
        @doc.at("IRS2441").add_child(Nokogiri::XML::Node.new('TotalQlfdExpensesOrLimitAmt', @doc))
        @doc.at("IRS2441 TotalQlfdExpensesOrLimitAmt").content = "1200"
        @direct_file_data = DirectFileData.new(@doc.to_s)
      end

      it "sets the correct values" do
        expect(@direct_file_data.fed_irs_1040_nr_filed).to be_truthy
        expect(@direct_file_data.fed_residential_clean_energy_credit_amount).to eq(1000)
        expect(@direct_file_data.fed_mortgage_interest_credit_amount).to eq(2000)
        expect(@direct_file_data.fed_adoption_credit_amount).to eq(3000)
        expect(@direct_file_data.fed_dc_homebuyer_credit_amount).to eq(4000)
        expect(@direct_file_data.total_qualifying_dependent_care_expenses).to eq(1200)
      end
    end

    context "when all fields are missing" do
      before do
        @direct_file_data = DirectFileData.new(@doc.to_s)
      end

      it "sets the correct values" do
        expect(@direct_file_data.fed_irs_1040_nr_filed).to be_falsey
        expect(@direct_file_data.fed_residential_clean_energy_credit_amount).to eq 0
        expect(@direct_file_data.fed_mortgage_interest_credit_amount).to eq 0
        expect(@direct_file_data.fed_adoption_credit_amount).to eq 0
        expect(@direct_file_data.fed_dc_homebuyer_credit_amount).to eq 0
      end
    end
  end

  describe '#dependents' do
    context "when there are dependents in the xml" do
      let(:xml) { StateFile::DirectFileApiResponseSampleService.new.read_xml('ny_five_dependents') }
      it 'returns an array of DirectFileData::Dependent objects' do

        expect(described_class.new(xml).dependents.count).to eq(5)
        expect(described_class.new(xml).dependents.first).to be_an_instance_of DirectFileData::Dependent
        expect(described_class.new(xml).dependents.first.ssn).to eq('444444444')
      end
    end

    context "when there are no dependents in the xml" do
      let(:xml) { StateFile::DirectFileApiResponseSampleService.new.read_xml('ny_javier') }
      it 'returns blank array' do

        expect(described_class.new(xml).dependents).to eq []
      end
    end

    context "when there are CTC dependents in the xml" do
      let(:xml) { StateFile::DirectFileApiResponseSampleService.new.read_xml('ny_zeus_8_deps') }
      it 'sets ctc_qualifying on those dependents' do

        expect(described_class.new(xml).dependents.select{ |d| d.ctc_qualifying }.length).to eq(3)
        expect(described_class.new(xml).dependents.select{ |d| d.ctc_qualifying == false }.length).to eq(5)
        expect(described_class.new(xml).dependents.length).to eq(8)
      end
    end

    context "when there are EIC dependents in the xml" do
      let(:xml) { StateFile::DirectFileApiResponseSampleService.new.read_xml('ny_zeus_8_deps') }
      it 'sets eic_qualifying on those dependents' do
        dependents = described_class.new(xml).dependents
        expect(dependents.select{ |d| d.eic_qualifying }.length).to eq(3)
        expect(dependents.select{ |d| d.eic_qualifying == false }.length).to eq(5)
        expect(dependents.select { |d| d.months_in_home == 7}.length).to eq(3)

        expect(described_class.new(xml).dependents.length).to eq(8)
      end
    end

    context "when there is a eic dependent with a disability" do
      let(:xml) { StateFile::DirectFileApiResponseSampleService.new.read_xml('ny_robert_mfj') }

      it "sets eic_disability on those dependents" do
        expect(described_class.new(xml).dependents.select{ |d| d.eic_qualifying }.length).to eq(3)
        expect(described_class.new(xml).dependents.select{ |d| d.eic_disability == 'yes' }.length).to eq(1)
      end
    end

    context "when there are dependents in AZ, the months_in_home is not populated" do
      let(:xml) { StateFile::DirectFileApiResponseSampleService.new.read_xml('az_johnny_mfj_8_deps') }

      it 'sets the months_in_home to nil' do
        expect(described_class.new(xml).dependents).to be_all { |d| d.months_in_home.nil? }
      end
    end

    context "when there are dependents in NY, the months_in_home IS populated" do
      let(:xml) { StateFile::DirectFileApiResponseSampleService.new.read_xml('ny_matthew') }

      it 'sets the months_in_home' do
        expect(described_class.new(xml).dependents).to be_all { |d| d.months_in_home.present? }
      end
    end

    context 'when there are dependents with missing tags' do
      let(:xml) { StateFile::DirectFileApiResponseSampleService.new.read_xml('ny_batman') }
      it 'still sets the dependents' do
        expect(described_class.new(xml).dependents.length).to eq(1)
      end
    end

    context 'when there are dependents with missing eic tags' do
      let(:xml) { StateFile::DirectFileApiResponseSampleService.new.read_xml('ny_zeus_depdropping') }
      it 'returns the correct array of DirectFileData::Dependent objects' do
        expect(described_class.new(xml).dependents.count).to eq(8)
        expect(described_class.new(xml).eitc_eligible_dependents.count).to eq(3)
        expect(described_class.new(xml).dependents.select{ |d| d.eic_student == 'yes' }.length).to eq(1)
        expect(described_class.new(xml).dependents.select{ |d| d.eic_disability == 'no' }.length).to eq(1)
        expect(described_class.new(xml).dependents.select{ |d| d.eic_student == 'unfilled' }.length).to eq(7)
        expect(described_class.new(xml).dependents.select{ |d| d.eic_disability == 'unfilled' }.length).to eq(7)
      end
    end
  end

  describe '#determine_eic_attribute' do
    let(:xml) { StateFile::DirectFileApiResponseSampleService.new.read_xml('ny_zeus_depdropping') }
    it 'returns yes for true' do
      expect(described_class.new(xml).determine_eic_attribute('true')).to eq('yes')
      expect(described_class.new(xml).determine_eic_attribute('false')).to eq('no')
      expect(described_class.new(xml).determine_eic_attribute(nil)).to eq('unfilled')
    end
  end

  describe '#surviving_spouse?' do
    context "when federal XML SurvivingSpouseInd has a value of 'X'" do
      let(:xml) { StateFile::DirectFileApiResponseSampleService.new.read_xml('ny_deceased_spouse') }
      it 'returns true' do
        expect(described_class.new(xml).spouse_deceased?).to eq(true)
      end
    end

    context "when federal XML SurvivingSpouseInd node not present" do
      let(:xml) { StateFile::DirectFileApiResponseSampleService.new.read_xml('ny_john_jane_no_eic') }
      it 'returns false' do
        expect(described_class.new(xml).spouse_deceased?).to eq(false)
      end
    end
  end

  describe '#spouse_is_a_dependent?' do
    let(:xml) { StateFile::DirectFileApiResponseSampleService.new.read_xml("az_bert") }
    it 'returns true' do
      expect(described_class.new(xml).spouse_is_a_dependent?).to eq(true)
    end
  end

  describe "#sum_of_1099r_payments_received" do
    it "returns the sum of TaxableAmt from 1099Rs" do
      xml = StateFile::DirectFileApiResponseSampleService.new.read_xml("az_richard_retirement_1099r")
      direct_file_data = DirectFileData.new(xml.to_s)

      expect(direct_file_data.sum_of_1099r_payments_received).to eq(1500)
    end
  end

  describe "DfW2" do
    let(:xml) { Nokogiri::XML(StateFile::DirectFileApiResponseSampleService.new.read_xml("az_alexis_hoh_w2_and_1099")) }
    let(:direct_file_data) { DirectFileData.new(xml.to_s) }
    let(:first_w2) { direct_file_data.w2s[0] }

    [
      ["EmployeeSSN", "400000003"],
      ["EmployerEIN", "234567891"],
      ["EmployerName", "Rose Apothecary"],
      ["EmployerStateIdNum", "12345"],
      ["AddressLine1Txt", "123 Twyla Road"],
      ["City", "Phoenix"],
      ["State", "AZ"],
      ["ZIP", "85034"],
      ["RetirementPlanInd", "X"],
      ["ThirdPartySickPayInd", "X"],
      ["StateAbbreviationCd", "AZ"],
      ["LocalityNm", "SomeCity"],
      ["WagesAmt", 35000],
      ["AllocatedTipsAmt", 50],
      ["DependentCareBenefitsAmt", 70],
      ["NonqualifiedPlansAmt", 10],
      ["StateWagesAmt", 35000],
      ["StateIncomeTaxAmt", 500],
      ["LocalWagesAndTipsAmt", 1350],
      ["LocalIncomeTaxAmt", 1000],
      ["WithholdingAmt", 3000],
    ].each do |node_name, current_value|
      describe "##{node_name}" do
        it "returns the value" do
          expect(first_w2.send(node_name)).to eq current_value
        end

        if current_value.is_a?(Integer)
          context "when the attribute is not present" do
            before do
              selector = DirectFileData::DfW2::SELECTORS[node_name.to_sym]
              xml.at('IRSW2').at(selector).remove
            end

            it "defaults to 0" do
              expect(first_w2.send(node_name)).to eq 0
            end
          end
        end
      end

      describe "##{node_name}=" do
        context "when the node is present" do
          if current_value.is_a?(Integer)
            it "sets the value" do
              first_w2.send("#{node_name}=", "500")
              expect(first_w2.send(node_name)).to eq 500
            end
          else
            it "sets the value" do
              first_w2.send("#{node_name}=", "New Value")
              expect(first_w2.send(node_name)).to eq "New Value"
            end
          end
        end

        context "when the node is not present" do
          before do
            selector = DirectFileData::DfW2::SELECTORS[node_name.to_sym]
            xml.at('IRSW2').at(selector).remove
          end

          if current_value.is_a?(Integer)
            it "sets the value" do
              first_w2.send("#{node_name}=", "500")
              expect(first_w2.send(node_name)).to eq 500
            end
          else
            it "sets the value" do
              first_w2.send("#{node_name}=", "New Value")
              expect(first_w2.send(node_name)).to eq "New Value"
            end
          end
        end
      end
    end
  end

  describe "Df1099R" do
    let(:direct_file_data) { DirectFileData.new(Nokogiri::XML(StateFile::DirectFileApiResponseSampleService.new.read_xml("nc_miranda_1099r")).to_s) }
    let(:first_1099r) { direct_file_data.form1099rs[0] }
    let(:second_1099r) { direct_file_data.form1099rs[1] }

    describe "#payer_name_control" do
      it "returns the value" do
        expect(first_1099r.payer_name_control).to eq "PAYE"
        expect(second_1099r.payer_name_control).to eq "PAYE"
      end
    end

    describe "#payer_name" do
      it "returns the value" do
        expect(first_1099r.payer_name).to eq "Payer Name"
        expect(second_1099r.payer_name).to eq "Payer 2 Name"
      end
    end

    describe "#payer_address_line1" do
      it "returns the value" do
        expect(first_1099r.payer_address_line1).to eq "2030 Pecan Street"
        expect(second_1099r.payer_address_line1).to eq nil
      end
    end

    describe "#payer_city_name" do
      it "returns the value" do
        expect(first_1099r.payer_city_name).to eq "Monroe"
        expect(second_1099r.payer_city_name).to eq nil
      end
    end

    describe "#payer_state_code" do
      it "returns the value" do
        expect(first_1099r.payer_state_code).to eq "NC"
        expect(second_1099r.payer_state_code).to eq nil
      end
    end

    describe "#payer_zip" do
      it "returns the value" do
        expect(first_1099r.payer_zip).to eq "05502"
        expect(second_1099r.payer_zip).to eq nil
      end
    end

    describe "#payer_identification_number" do
      it "returns the value" do
        expect(first_1099r.payer_identification_number).to eq "000000008"
        expect(second_1099r.payer_identification_number).to eq "000000009"
      end
    end

    describe "#phone_number" do
      it "returns the value" do
        expect(first_1099r.phone_number).to eq "2025551212"
        expect(second_1099r.phone_number).to eq nil
      end
    end

    describe "#gross_distribution_amount" do
      it "returns the value" do
        expect(first_1099r.gross_distribution_amount).to eq 200
        expect(second_1099r.gross_distribution_amount).to eq 4000
      end
    end

    describe "#taxable_amount" do
      it "returns the value" do
        expect(first_1099r.taxable_amount).to eq 1000
        expect(second_1099r.taxable_amount).to eq 3000
      end
    end

    describe "#federal_income_tax_withheld_amount" do
      it "returns the value" do
        expect(first_1099r.federal_income_tax_withheld_amount).to eq 300
        expect(second_1099r.federal_income_tax_withheld_amount).to eq 0
      end
    end

    describe "#distribution_code" do
      it "returns the value" do
        expect(first_1099r.distribution_code).to eq "7"
        expect(second_1099r.distribution_code).to eq nil
      end
    end

    describe "#standard" do
      it "returns the value" do
        expect(first_1099r.standard).to eq "S"
        expect(second_1099r.standard).to eq "N"
      end
    end

    describe "#state_tax_withheld_amount" do
      it "returns the value" do
        expect(first_1099r.state_tax_withheld_amount).to eq 0
        expect(second_1099r.state_tax_withheld_amount).to eq 0
      end
    end
    describe "#state_code" do
      it "returns the value" do
        expect(first_1099r.state_code).to eq nil
        expect(second_1099r.state_code).to eq "NC"
      end
    end
    describe "#payer_state_identification_number" do
      it "returns the value" do
        expect(first_1099r.payer_state_identification_number).to eq nil
        expect(second_1099r.payer_state_identification_number).to eq nil
      end
    end
    describe "#state_distribution_amount" do
      it "returns the value" do
        expect(first_1099r.state_distribution_amount).to eq 0
        expect(second_1099r.state_distribution_amount).to eq 2000
      end
    end

    describe "#recipient_ssn" do
      it "returns the value" do
        expect(first_1099r.recipient_ssn).to eq '400001032'
        expect(second_1099r.recipient_ssn).to eq '400001032'
      end
    end

    describe "#recipient_name" do
      it "returns the value" do
        expect(first_1099r.recipient_name).to eq 'Susan Miranda'
        expect(second_1099r.recipient_name).to eq 'Susan Miranda'
      end
    end

    # TODO: Once we have better 1099R example, replace with one that has values for these
    describe "#taxable_amount_not_determined" do
      it "returns the value" do
        expect(first_1099r.taxable_amount_not_determined).to eq nil
        expect(second_1099r.taxable_amount_not_determined).to eq nil
      end
    end

    describe "#total_distribution" do
      it "returns the value" do
        expect(first_1099r.total_distribution).to eq nil
        expect(second_1099r.total_distribution).to eq nil
      end
    end

    describe "#capital_gain_amount" do
      it "returns the value" do
        expect(first_1099r.capital_gain_amount).to eq 0
        expect(second_1099r.capital_gain_amount).to eq 0
      end
    end

    describe "#designated_roth_account_first_year" do
      it "returns the value" do
        expect(first_1099r.designated_roth_account_first_year).to eq nil
        expect(second_1099r.designated_roth_account_first_year).to eq nil
      end
    end
  end
end
