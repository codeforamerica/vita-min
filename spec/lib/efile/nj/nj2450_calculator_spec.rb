require 'rails_helper'

describe Efile::Nj::Nj2450Calculator do
  let(:intake) { create(:state_file_nj_intake, :df_data_mfj) }
  let(:primary_ssn_from_fixture) { intake.primary.ssn }
  let(:spouse_ssn_from_fixture) { intake.spouse.ssn }
  let(:nj1040_calculator) do
    Efile::Nj::Nj1040Calculator.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake,
    )
  end
  let(:instance) { nj1040_calculator.instance_variable_get(:@nj2450_primary) }

  before do
    instance.calculate
  end

  context "primary" do
    context "column a" do
      context "multiple w2s that individually do not exceed #{Efile::Nj::Nj1040Calculator::EXCESS_UI_WF_SWF_MAX} and total more than #{Efile::Nj::Nj1040Calculator::EXCESS_UI_WF_SWF_MAX}" do 
        let!(:w2_1) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn_from_fixture, box14_ui_hc_wd: 100) }
        let!(:w2_2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn_from_fixture, box14_ui_hc_wd: 134) }

        before do
          instance.calculate
        end

        it "sums ui/wf/swf and ui/hc/wd" do
          expected_sum = 234
          expect(instance.lines[:NJ2450_COLUMN_A_TOTAL_PRIMARY].value).to eq(expected_sum)
        end

        it "subtracts max contribution amount" do
          expected_difference = 54
          expect(instance.lines[:NJ2450_COLUMN_A_EXCESS_PRIMARY].value).to eq(expected_difference)
        end
      end
    end

    context "column c" do
      context "multiple w2s that individually do not exceed #{Efile::Nj::Nj1040Calculator::EXCESS_FLI_MAX} and total more than #{Efile::Nj::Nj1040Calculator::EXCESS_FLI_MAX}" do 
        let!(:w2_1) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn_from_fixture, box14_fli: 100) }
        let!(:w2_2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn_from_fixture, box14_fli: 134) }

        before do
          instance.calculate
        end

        it "sums fli" do
          expected_sum = 234
          expect(instance.lines[:NJ2450_COLUMN_C_TOTAL_PRIMARY].value).to eq(expected_sum)
        end

        it "subtracts max contribution amount" do
          expected_difference = 89
          expect(instance.lines[:NJ2450_COLUMN_C_EXCESS_PRIMARY].value).to eq(expected_difference)
        end
      end
    end
  end


  context "mfj spouse" do
    let(:instance) { nj1040_calculator.instance_variable_get(:@nj2450_spouse) }
    context "columnn a" do
      context "multiple w2s that individually do not exceed #{Efile::Nj::Nj1040Calculator::EXCESS_UI_WF_SWF_MAX} and total more than #{Efile::Nj::Nj1040Calculator::EXCESS_UI_WF_SWF_MAX}" do 
        let!(:w2_1) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn_from_fixture, box14_ui_hc_wd: 100) }
        let!(:w2_2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn_from_fixture, box14_ui_hc_wd: 134) }

        before do
          instance.calculate
        end

        it "sums ui/wf/swf and ui/hc/wd" do
          expected_sum = 234 # w2_1 box14_ui_hc_wd 100 + w1_2 box14_ui_hc_wd 134
          expect(instance.lines[:NJ2450_COLUMN_A_TOTAL_SPOUSE].value).to eq(expected_sum)
        end

        it "subtracts max contribution amount" do
          expected_difference = 54
          expect(instance.lines[:NJ2450_COLUMN_A_EXCESS_SPOUSE].value).to eq(expected_difference)
        end
      end
    end

    context "column c" do
      context "multiple w2s that individually do not exceed #{Efile::Nj::Nj1040Calculator::EXCESS_FLI_MAX} and total more than #{Efile::Nj::Nj1040Calculator::EXCESS_FLI_MAX}" do 
        let!(:w2_1) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn_from_fixture, box14_fli: 100) }
        let!(:w2_2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn_from_fixture, box14_fli: 134) }

        before do
          instance.calculate
        end

        it "sums fli" do
          expected_sum = 234 # w2_1 box14_fli 100 + w1_2 box14_fli 134
          expect(instance.lines[:NJ2450_COLUMN_C_TOTAL_SPOUSE].value).to eq(expected_sum)
        end

        it "subtracts max contribution amount" do
          expected_difference = 89
          expect(instance.lines[:NJ2450_COLUMN_C_EXCESS_SPOUSE].value).to eq(expected_difference)
        end
      end
    end
  end
end
