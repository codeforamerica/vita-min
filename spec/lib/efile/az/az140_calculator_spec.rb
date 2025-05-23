require 'rails_helper'

describe Efile::Az::Az140Calculator do
  let(:intake) { create(:state_file_az_intake, eligibility_lived_in_state: 1) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end

  context "when claiming multiple dependents of different classifications" do
    let(:intake) { create(:state_file_az_johnny_intake) }

    it "counts the dependents correctly by their classifications" do
      instance.calculate
      expect(instance.lines[:AZ140_LINE_10A].value).to eq(4)
      expect(instance.lines[:AZ140_LINE_10B].value).to eq(4)
      expect(instance.lines[:AZ140_LINE_11A].value).to eq(1)
    end
  end

  context "line 5c" do
    it "fills in value with line 13 value from Az321 calculator" do
      allow_any_instance_of(Efile::Az::Az321Calculator).to receive(:calculate_line_13).and_return 210
      instance.calculate
      expect(instance.lines[:AZ140_CCWS_LINE_5c].value).to eq(210)
    end
  end

  context "sets 6c correctly" do
    before do
      allow(instance).to receive(:calculate_ccws_line_4c).and_return 10_000
    end

    context "line 5c is less than 4c" do
      before do
        allow(instance).to receive(:calculate_ccws_line_5c).and_return 2_000
      end

      it "returns the difference" do
        instance.calculate
        expect(instance.lines[:AZ140_CCWS_LINE_6c].value).to eq(8_000)
      end
    end

    context "line 5c is greater than 4c" do
      before do
        allow(instance).to receive(:calculate_ccws_line_5c).and_return 12_000
      end

      it "returns 0" do
        instance.calculate
        expect(instance.lines[:AZ140_CCWS_LINE_6c].value).to eq(0)
      end
    end
  end

  context 'sets line 7c correctly' do
    before do
      intake.charitable_cash_amount = 50
      intake.charitable_noncash_amount = 50
      intake.charitable_contributions = 'yes'
      allow(instance).to receive(:calculate_line_42).and_return 10_000
      allow(instance).to receive(:calculate_line_43).and_return 2_000
    end

    # 31% of 100 (50+50)
    it 'sets the credit to the maximum amount' do
      instance.calculate
      expect(instance.lines[:AZ140_CCWS_LINE_7c].value).to eq(33)
      expect(instance.lines[:AZ140_LINE_44].value).to eq(33)
      expect(instance.lines[:AZ140_LINE_45].value).to eq(7_967)
    end
  end

  describe "Line 8" do
    let(:senior_cutoff_date) { Date.new((MultiTenantService.statefile.current_tax_year - 70), 12, 31) }

    context "when both primary and spouse are older than 65" do
      let(:intake) { create(:state_file_az_intake, :with_senior_spouse, primary_birth_date: senior_cutoff_date, spouse_birth_date: senior_cutoff_date) }

      it "returns 2" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_8].value).to eq(2)
      end
    end

    context "when only the primary is over 65" do
      let(:intake) { create(:state_file_az_intake, :with_spouse, primary_birth_date: senior_cutoff_date) }

      it "returns 1" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_8].value).to eq(1)
      end
    end

    context "when born a day after the senior cutoff date" do
      let(:intake) { create(:state_file_az_intake, :with_senior_spouse, primary_birth_date: senior_cutoff_date + 1.day, spouse_birth_date: senior_cutoff_date) }

      it "it counts them" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_8].value).to eq(2)
      end
    end
  end

  describe "Line 28" do
    context "has no interest reports with interest on government bonds" do
      it "returns 0" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_28].value).to eq(0)
      end
    end

    context "has interest reports with interest on government bonds" do
      let(:intake) { create(:state_file_az_intake, :df_data_1099_int) }

      it "returns sum of the interest on government bonds" do
        intake.direct_file_json_data.interest_reports.first&.interest_on_government_bonds = "2.00"
        instance.calculate
        expect(instance.lines[:AZ140_LINE_28].value).to eq(2)
      end
    end
  end

  describe "Line 29a" do
    context "has qualifying pension plan" do
      before do
        allow_any_instance_of(StateFileAzIntake).to receive(:sum_1099_r_followup_type_for_filer).and_call_original
      end

      context "primary has pension plan amount over 2500" do
        before do
          allow_any_instance_of(StateFileAzIntake).to receive(:sum_1099_r_followup_type_for_filer).with(:primary, :income_source_pension_plan?).and_return 10_000
        end

        it "returns max subtraction allowed (2500)" do
          instance.calculate
          expect(instance.lines[:AZ140_LINE_29A].value).to eq(2500)
        end
      end

      context "primary has pension plan amount under 2500" do
        before do
          allow_any_instance_of(StateFileAzIntake).to receive(:sum_1099_r_followup_type_for_filer).with(:primary, :income_source_pension_plan?).and_return 2455
        end

        it "returns primary pension plan amount" do
          instance.calculate
          expect(instance.lines[:AZ140_LINE_29A].value).to eq(2455)
        end
      end

      context "mfj" do
        before do
          allow_any_instance_of(StateFileAzIntake).to receive(:filing_status_mfj?).and_return true
          allow_any_instance_of(StateFileAzIntake).to receive(:sum_1099_r_followup_type_for_filer).with(:primary, :income_source_pension_plan?).and_return 100
        end

        context "spouse has pension plan amount over 2500" do
          before do
            allow_any_instance_of(StateFileAzIntake).to receive(:sum_1099_r_followup_type_for_filer).with(:spouse, :income_source_pension_plan?).and_return 2501
          end

          it "returns max subtraction allowed (2500) + primary pension subtraction" do
            instance.calculate
            expect(instance.lines[:AZ140_LINE_29A].value).to eq(2600)
          end
        end

        context "spouse has pension plan amount under 2500" do
          before do
            allow_any_instance_of(StateFileAzIntake).to receive(:sum_1099_r_followup_type_for_filer).with(:spouse, :income_source_pension_plan?).and_return 2499
          end

          it "returns max subtraction allowed (2500) + primary pension subtraction" do
            instance.calculate
            expect(instance.lines[:AZ140_LINE_29A].value).to eq(2599)
          end
        end
      end
    end

    describe "Line 29b" do
      context "has retirement income from uniformed services" do
        before do
          allow_any_instance_of(StateFileAzIntake).to receive(:sum_1099_r_followup_type_for_filer).and_call_original
        end

        context "single" do
          before do
            allow_any_instance_of(StateFileAzIntake).to receive(:sum_1099_r_followup_type_for_filer).with(:primary, :income_source_uniformed_services?).and_return 199
          end

          it "returns sum of uniformed services retirement income" do
            instance.calculate
            expect(instance.lines[:AZ140_LINE_29B].value).to eq(199)
          end
        end

        context "mfj" do
          before do
            allow_any_instance_of(StateFileAzIntake).to receive(:filing_status_mfj?).and_return true
            allow_any_instance_of(StateFileAzIntake).to receive(:sum_1099_r_followup_type_for_filer).with(:primary, :income_source_uniformed_services?).and_return 100
            allow_any_instance_of(StateFileAzIntake).to receive(:sum_1099_r_followup_type_for_filer).with(:spouse, :income_source_uniformed_services?).and_return 300
          end

          it "returns sum of both retirement incomes" do
            instance.calculate
            expect(instance.lines[:AZ140_LINE_29B].value).to eq(400)
          end
        end
      end

      context "has no qualifying retirement income from uniformed services" do
        before do
          allow_any_instance_of(StateFileAzIntake).to receive(:sum_1099_r_followup_type_for_filer).and_call_original
          allow_any_instance_of(StateFileAzIntake).to receive(:sum_1099_r_followup_type_for_filer).with(:primary, :income_source_uniformed_services?).and_return 0
          allow_any_instance_of(StateFileAzIntake).to receive(:sum_1099_r_followup_type_for_filer).with(:spouse, :income_source_uniformed_services?).and_return 0
        end

        it "returns 0" do
          instance.calculate
          expect(instance.lines[:AZ140_LINE_29B].value).to eq(0)
        end
      end
    end


    context "has qualifying no qualifying pension plan" do
      before do
        allow_any_instance_of(StateFileAzIntake).to receive(:sum_1099_r_followup_type_for_filer).and_call_original
        allow_any_instance_of(StateFileAzIntake).to receive(:sum_1099_r_followup_type_for_filer).with(:primary, :income_source_uniformed_services?).and_return 0
        allow_any_instance_of(StateFileAzIntake).to receive(:sum_1099_r_followup_type_for_filer).with(:spouse, :income_source_uniformed_services?).and_return 0
      end

      it "returns 0" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_29B].value).to eq(0)
      end
    end
  end

  describe "Line 35" do
    before do
      intake.direct_file_data.fed_taxable_ssb = 100
    end
    it "subtracts lines 24 through 34c from line 19" do
      allow(instance).to receive(:calculate_line_19).and_return 700
      allow(instance).to receive(:calculate_line_28).and_return 100
      allow(instance).to receive(:calculate_line_29a).and_return 100
      allow(instance).to receive(:calculate_line_29b).and_return 100
      allow(instance).to receive(:calculate_line_31).and_return 100
      allow(instance).to receive(:calculate_line_32).and_return 100
      instance.calculate
      expect(instance.lines[:AZ140_LINE_35].value).to eq(100)
    end
  end

  describe "Line 43 and 43S: standard deduction" do
    let(:intake) { create(:state_file_az_intake, filing_status: filing_status) }

    context "single" do
      let(:filing_status) { "single" }

      it "sets the standard deduction correctly" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_43].value).to eq(14_600)
        expect(instance.lines[:AZ140_LINE_43S].value).to eq('Standard')
      end
    end

    context "mfj" do
      let(:filing_status) { "married_filing_jointly" }

      it "sets the standard deduction correctly" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_43].value).to eq(29_200)
        expect(instance.lines[:AZ140_LINE_43S].value).to eq('Standard')
      end
    end

    context "hoh" do
      context "actually hoh" do
        let(:filing_status) { "head_of_household" }

        it "sets the standard deduction correctly" do
          instance.calculate
          expect(instance.lines[:AZ140_LINE_43].value).to eq(21_900)
          expect(instance.lines[:AZ140_LINE_43S].value).to eq('Standard')
        end
      end

      context "actually qss" do
        let(:filing_status) { "qualifying_widow" }

        it "sets the standard deduction to the same amount as hoh" do
          instance.calculate
          expect(instance.lines[:AZ140_LINE_43].value).to eq(21_900)
          expect(instance.lines[:AZ140_LINE_43S].value).to eq('Standard')
        end
      end
    end
  end

  describe "Line 45: Arizona taxable income" do
    context "line 42 - (line 43 + 44) is more than 0" do
      it "enters the amount" do
        allow(instance).to receive(:calculate_line_42).and_return 3_000
        allow(instance).to receive(:calculate_line_43).and_return 1_000
        allow(instance).to receive(:calculate_line_44).and_return 1_000

        instance.calculate
        expect(instance.lines[:AZ140_LINE_45].value).to eq(1_000)
      end
    end

    context "line 42 - (line 43 + 44) is less than 0" do
      it "enters 0" do
        allow(instance).to receive(:calculate_line_42).and_return 1_000
        allow(instance).to receive(:calculate_line_43).and_return 1_000
        allow(instance).to receive(:calculate_line_44).and_return 1_000

        instance.calculate
        expect(instance.lines[:AZ140_LINE_45].value).to eq(0)
      end
    end
  end

  describe "Line 46: tax" do
    it "multiplies line 45 by 0.025" do
      allow(instance).to receive(:calculate_line_45).and_return 20_000

      instance.calculate
      expect(instance.lines[:AZ140_LINE_46].value).to eq(500)
    end

    it "rounds the result" do
      allow(instance).to receive(:calculate_line_45).and_return 20_500

      instance.calculate
      expect(instance.lines[:AZ140_LINE_46].value).to eq(513)
    end
  end

  describe "Line 51" do
    it 'populates from AZ-301 line 62' do
      allow_any_instance_of(Efile::Az::Az301Calculator).to receive(:calculate_line_60).and_return 100
      instance.calculate
      expect(instance.lines[:AZ140_LINE_51].value).to eq(100)
    end
  end

  describe "Line 52" do
    context "the sum of lines 49, 50, 51 is less than line 48" do
      it "subtracts lines 49, 50, and 51 from 48" do
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_48).and_return 428
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_49).and_return 25
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_50).and_return 5
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_51).and_return 33
        instance.calculate
        expect(instance.lines[:AZ140_LINE_52].value).to eq(365)
      end
    end

    context "the sum of lines 49, 50, and 51 are more than line 48" do
      it "returns 0" do
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_48).and_return 400
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_49).and_return 200
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_50).and_return 200
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_51).and_return 200
        instance.calculate
        expect(instance.lines[:AZ140_LINE_52].value).to eq(0)
      end
    end

  end

  describe 'Line 53: AZ Income Tax Withheld' do
    let(:intake) {
      # tycho has $900 StateIncomeTaxAmt on a w2 & $50 StateTaxWithheldAmt on a 1099r
      create(:state_file_az_intake,
             :with_1099_rs_synced,
             :with_w2s_synced,
             raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('az_tycho_single_with_1099r'),
             raw_direct_file_intake_data: StateFile::DirectFileApiResponseSampleService.new.read_json('az_tycho_single_with_1099r'))
    }
    let!(:state_file1099_g) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 100) }

    it 'sums the AZ tax withheld from w2s, 1099gs and 1099rs' do
      instance.calculate
      expect(instance.lines[:AZ140_LINE_53].value).to eq(900 + 50 + 100)
    end

    context "with nil state_income_tax_amount for W2" do
      before do
        intake.state_file_w2s.first&.update(state_income_tax_amount: nil)
      end

      it "sums up all relevant values without error" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_53].value).to eq(50 + 100)
      end
    end

    context "with nil state_income_tax_amount for W2" do
      before do
        intake.state_file1099_rs.first&.update(state_tax_withheld_amount: nil)
      end

      it "sums up all relevant values without error" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_53].value).to eq(900 + 100)
      end
    end
  end

  describe "Line 55: Extension Payments" do
    context "when there are no extension payments" do
      before do
        allow(intake).to receive(:extension_payments_amount).and_return 0
      end

      it "returns nil" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_55].value).to eq(0)
      end
    end

    context "when there are extension payments" do
      before do
        intake.paid_extension_payments = 'yes'
        allow(intake).to receive(:extension_payments_amount).and_return 2112
      end

      it "returns the amount of the payment" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_55].value).to eq(2112)
      end
    end
  end

  describe "Line 56: Increased Excise Tax Credit" do
    before do
      allow(intake).to receive(:disqualified_from_excise_credit_fyst?).and_return false
    end

    context "when the client is disqualified because of the answers they gave during intake" do
      it "sets the amount to 0" do
        allow(intake).to receive(:disqualified_from_excise_credit_fyst?).and_return true
        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
      end
    end

    context "when the client is disqualified for having too much income" do
      context "fed agi above 12,501" do
        before do
          intake.direct_file_data.fed_agi = 12_501
        end

        it "when single sets the amount to 0" do
          intake.direct_file_data.filing_status = 1 # single
          instance.calculate
          expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
        end

        it "when mfs sets the amount to 0" do
          intake.direct_file_data.filing_status = 3 # mfs
          instance.calculate
          expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
        end
      end

      context "fed agi above 25,001" do
        before do
          intake.direct_file_data.fed_agi = 25_001
        end

        it "when mfj sets the amount to 0" do
          intake.direct_file_data.filing_status = 2 # mfj
          instance.calculate
          expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
        end

        it "when hoh sets the amount to 0" do
          intake.direct_file_data.filing_status = 4 # hoh
          instance.calculate
          expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
        end
      end
    end

    context "single filer with one dependent" do
      it "sets the credit to the correct amount" do
        create :state_file_dependent, intake: intake, dob: 7.years.ago
        intake.direct_file_data.filing_status = 1 # single
        intake.direct_file_data.fed_agi = 12_500 # qualifying agi

        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(50) # (1 filer + 1 dependent) * 25
      end
    end

    context "mfs filer with one dependent" do
      it "sets the credit to the correct amount" do
        create :state_file_dependent, intake: intake, dob: 7.years.ago
        intake.direct_file_data.filing_status = 3 # mfs
        intake.direct_file_data.fed_agi = 12_500 # qualifying agi

        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(50) # (1 filer + 1 dependent) * 25
      end
    end

    context "mfj filer with one dependent" do
      let (:intake) { create :state_file_az_intake, :with_spouse }

      it "sets the credit to the correct amount" do
        create :state_file_dependent, intake: intake, dob: 7.years.ago
        intake.direct_file_data.fed_agi = 25_000 # qualifying agi

        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(75) # (2 filers + 1 dependent) * 25
      end
    end

    context "mfj when one filer has an SSN which is not valid for employment" do
      let (:intake) { create :state_file_az_intake, :with_spouse }

      it "sets the credit to the correct amount when primary has ssn_not_valid_for_employment" do
        create :state_file_dependent, intake: intake, dob: 7.years.ago
        intake.direct_file_data.fed_agi = 25_000 # qualifying agi
        intake.direct_file_json_data.primary_filer.ssn_not_valid_for_employment = true

        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(0) # an inelegible primary sets credit to 0
      end

      it "sets the credit to the correct amount when spouse has ssn_not_valid_for_employment" do
        create :state_file_dependent, intake: intake, dob: 7.years.ago
        intake.direct_file_data.fed_agi = 25_000 # qualifying agi
        intake.direct_file_json_data.spouse_filer.ssn_not_valid_for_employment = true

        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(50) # (1 filers + 1 dependent) * 25
      end
    end

    context "hoh filer with one dependent" do
      it "sets the credit to the correct amount" do
        create :state_file_dependent, intake: intake, dob: 7.years.ago
        intake.direct_file_data.filing_status = 4 # hoh
        intake.direct_file_data.fed_agi = 25_000 # # qualifying agi
        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(50) # (1 filer + 1 dependent) * 25
      end
    end

    context "when the client qualifies for the maximum credit" do
      it "sets the credit to the maximum amount" do
        intake.direct_file_data.filing_status = 1 # single
        intake.direct_file_data.fed_agi = 12_500 # qualifying agi
        create :state_file_dependent, intake: intake, dob: 7.years.ago
        create :state_file_dependent, intake: intake, dob: 5.years.ago
        create :state_file_dependent, intake: intake, dob: 3.years.ago
        create :state_file_dependent, intake: intake, dob: 1.years.ago
        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(100) # (1 filer + 4 dependents) * 25 = 125 but max is 100
      end
    end

    context "mfj filer, one incarcerated, no dependents" do
      let (:intake) { create :state_file_az_intake, :with_spouse }

      it "calculates the credit without incarcerated filer" do
        intake.direct_file_data.fed_agi = 12_500 # qualifying agi
        intake.update(primary_was_incarcerated: "no", spouse_was_incarcerated: "yes")
        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(25) # (1 filer) * 25 = 25
      end

      it "handles the old column for now" do
        intake.direct_file_data.fed_agi = 12_500 # qualifying agi
        intake.update(was_incarcerated: "no")
        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(50) # (2 filers) * 25 = 25
      end
    end

    context "single filer with four dependents with some credit already claimed" do
      it "adjusts the max credit" do
        intake.direct_file_data.filing_status = 1 # single
        intake.direct_file_data.fed_agi = 12_500 # qualifying agi
        create :state_file_dependent, intake: intake, dob: 7.years.ago
        create :state_file_dependent, intake: intake, dob: 5.years.ago
        create :state_file_dependent, intake: intake, dob: 3.years.ago
        create :state_file_dependent, intake: intake, dob: 1.years.ago
        intake.update(household_excise_credit_claimed: "yes", household_excise_credit_claimed_amount: 40)
        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(60) # (1 filer + 4 dependents) * 25 = 125 but max is 60
      end
    end

    context "single filer with four dependents with some credit claimed over total amount" do
      it "sets the credit to 0" do
        intake.direct_file_data.filing_status = 1 # single
        intake.direct_file_data.fed_agi = 12_500 # qualifying agi
        intake.dependents.create(dob: 7.years.ago)
        intake.dependents.create(dob: 5.years.ago)
        intake.dependents.create(dob: 3.years.ago)
        intake.dependents.create(dob: 1.years.ago)
        intake.update(household_excise_credit_claimed: "yes", household_excise_credit_claimed_amount: 110)
        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(0) # (1 filer + 4 dependents) * 25 = 125 but max is 0
      end
    end

    # TODO: [JH] i don't....understand this test? was copied from commit a674f6f
    context "filing status is qualifying widow" do
      it "sets the family income tax credit and excise credit to 0" do
        intake.direct_file_data.filing_status = 5 # qualifying_widow
        instance.calculate
        expect(instance.lines[:AZ140_LINE_50].value).to eq(0)
        expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
      end
    end
  end

  describe "Line 59" do
    it "sums lines 53 through 58" do
      allow(instance).to receive(:calculate_line_53).and_return(100)
      allow(instance).to receive(:calculate_line_55).and_return(300)
      allow(instance).to receive(:calculate_line_56).and_return(400)
      instance.calculate
      expect(instance.lines[:AZ140_LINE_59].value).to eq(800)
    end
  end

  describe "refund_or_owed_amount" do
    it "subtracts owed amount from refund amount" do
      allow(instance).to receive(:calculate_line_79).and_return 20
      allow(instance).to receive(:calculate_line_80).and_return 0
      instance.calculate
      expect(instance.refund_or_owed_amount).to eq(20)
    end
  end
end
