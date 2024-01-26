require 'rails_helper'

describe DirectFileData do
  describe '#ny_public_employee_retirement_contributions' do
    let(:desc1) { '414H' }
    let(:desc2) { '414 (H)' }

    before do
      xml = File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml'))
      doc = Nokogiri::XML(xml)
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
  end

  describe '#fed_adjustments_claimed' do

    before do
      xml = File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml'))
      @doc = Nokogiri::XML(xml)
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
      xml = File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml'))
      @doc = Nokogiri::XML(xml)
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
      xml = File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml'))
      @doc = Nokogiri::XML(xml)
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
      xml = File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml'))
      @doc = Nokogiri::XML(xml)
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
      xml = File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml'))
      @doc = Nokogiri::XML(xml)
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
        @direct_file_data = DirectFileData.new(@doc.to_s)
      end

      it "sets the correct values" do
        expect(@direct_file_data.fed_irs_1040_nr_filed).to be_truthy
        expect(@direct_file_data.fed_residential_clean_energy_credit_amount).to eq(1000)
        expect(@direct_file_data.fed_mortgage_interest_credit_amount).to eq(2000)
        expect(@direct_file_data.fed_adoption_credit_amount).to eq(3000)
        expect(@direct_file_data.fed_dc_homebuyer_credit_amount).to eq(4000)
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
      let(:xml) { File.read(Rails.root.join('spec/fixtures/files/fed_return_five_dependents_ny.xml')) }
      it 'returns an array of DirectFileData::Dependent objects' do

        expect(described_class.new(xml).dependents.count).to eq(5)
        expect(described_class.new(xml).dependents.first).to be_an_instance_of DirectFileData::Dependent
        expect(described_class.new(xml).dependents.first.ssn).to eq('444444444')
      end
    end

    context "when there are no dependents in the xml" do
      let(:xml) { File.read(Rails.root.join('spec/fixtures/files/fed_return_javier_ny.xml')) }
      it 'returns blank array' do

        expect(described_class.new(xml).dependents).to eq []
      end
    end

    context "when there are CTC dependents in the xml" do
      let(:xml) { File.read(Rails.root.join('spec/fixtures/files/fed_return_zeus_8_deps_ny.xml')) }
      it 'sets ctc_qualifying on those dependents' do

        expect(described_class.new(xml).dependents.select{ |d| d.ctc_qualifying }.length).to eq(3)
        expect(described_class.new(xml).dependents.select{ |d| d.ctc_qualifying == false }.length).to eq(5)
        expect(described_class.new(xml).dependents.length).to eq(8)
      end
    end

    context "when there are EIC dependents in the xml" do
      let(:xml) { File.read(Rails.root.join('spec/fixtures/files/fed_return_zeus_8_deps_ny.xml')) }
      it 'sets eic_qualifying on those dependents' do
        dependents = described_class.new(xml).dependents
        expect(dependents.select{ |d| d.eic_qualifying }.length).to eq(3)
        expect(dependents.select{ |d| d.eic_qualifying == false }.length).to eq(5)
        expect(dependents.select { |d| d.months_in_home == 7}.length).to eq(3)

        expect(described_class.new(xml).dependents.length).to eq(8)
      end
    end

    context "when there is a eic dependent with a disability" do
      let(:xml) { File.read(Rails.root.join('spec/fixtures/files/fed_return_robert_mfj_ny.xml')) }

      it "sets eic_disability on those dependents" do
        expect(described_class.new(xml).dependents.select{ |d| d.eic_qualifying }.length).to eq(3)
        expect(described_class.new(xml).dependents.select{ |d| d.eic_disability == 'yes' }.length).to eq(1)
      end
    end

    context "when there are dependents in AZ, the months_in_home is not populated" do
      let(:xml) { File.read(Rails.root.join('spec/fixtures/files/fed_return_johnny_mfj_8_deps_az.xml')) }

      it 'sets the months_in_home to nil' do
        expect(described_class.new(xml).dependents).to be_all { |d| d.months_in_home.nil? }
      end
    end

    context "when there are dependents in NY, the months_in_home IS populated" do
      let(:xml) { File.read(Rails.root.join('spec/fixtures/files/fed_return_matthew_ny.xml')) }

      it 'sets the months_in_home' do
        expect(described_class.new(xml).dependents).to be_all { |d| d.months_in_home.present? }
      end
    end

    context 'when there are dependents with missing tags' do
      let(:xml) { File.read(Rails.root.join('spec/fixtures/files/fed_return_batman_ny.xml')) }
      it 'still sets the dependents' do
        expect(described_class.new(xml).dependents.length).to eq(1)
      end
    end

    context 'when there are dependents with missing eic tags' do
      let(:xml) { File.read(Rails.root.join('spec/fixtures/files/fed_return_zeus_depdropping_ny.xml')) }
      it 'returns an array of DirectFileData::Dependent objects' do
        expect(described_class.new(xml).dependents.count).to eq(8)
        expect(described_class.new(xml).eitc_eligible_dependents.count).to eq(3)
        expect(described_class.new(xml).dependents.select{ |d| d.eic_student == 'yes' }.length).to eq(1)
        expect(described_class.new(xml).dependents.select{ |d| d.eic_disability == 'no' }.length).to eq(1)
        expect(described_class.new(xml).dependents.select{ |d| d.eic_student == 'unfilled' }.length).to eq(7)
        expect(described_class.new(xml).dependents.select{ |d| d.eic_disability == 'unfilled' }.length).to eq(7)
      end
    end
  end
end
