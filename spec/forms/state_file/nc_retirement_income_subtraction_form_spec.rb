require 'rails_helper'

RSpec.describe StateFile::NcRetirementIncomeSubtractionForm, type: :model do
  describe "validations" do
    it { should validate_presence_of :income_source }

    context "must answer follow-up question" do
      let(:follow_up) { create(:state_file_nc1099_r_followup) }

      context "they checked one of the qualifying conditions" do
        it "is valid" do
          bailey_valid_params = {
            income_source: "bailey_settlement",
            bailey_settlement_at_least_five_years: "yes",
            bailey_settlement_from_retirement_plan: "no",
            bailey_settlement_none_apply: false,
            uniformed_services_retired: "no",
            uniformed_services_qualifying_plan: "no",
            uniformed_services_none_apply: false,
          }
          expect(described_class.new(follow_up, bailey_valid_params).valid?).to eq true

          uniformed_valid_params = {
            income_source: "uniformed_services",
            bailey_settlement_at_least_five_years: "no",
            bailey_settlement_from_retirement_plan: "no",
            bailey_settlement_none_apply: false,
            uniformed_services_retired: "no",
            uniformed_services_qualifying_plan: "yes",
            uniformed_services_none_apply: false,
          }
          expect(described_class.new(follow_up, uniformed_valid_params).valid?).to eq true
        end
      end

      ["bailey_settlement", "uniformed_services"].each do |income_source_answer|
        context "income source is #{income_source_answer}" do
          let(:params) do
            {
              income_source: income_source_answer,
              bailey_settlement_at_least_five_years: "no",
              bailey_settlement_from_retirement_plan: "no",
              bailey_settlement_none_apply: defined?(bailey_settlement_none_apply) ? bailey_settlement_none_apply : "no",
              uniformed_services_retired: "no",
              uniformed_services_qualifying_plan: "no",
              uniformed_services_none_apply: defined?(uniformed_services_none_apply) ? uniformed_services_none_apply : "no",
            }
          end

          context "they did not check none apply" do
            let("#{income_source_answer}_none_apply") { "no" }

            it "is invalid" do
              form = described_class.new(follow_up, params)
              expect(form.valid?).to eq false
            end
          end

          context "they checked none apply" do
            let("#{income_source_answer}_none_apply") { "yes" }

            it "is invalid" do
              form = described_class.new(follow_up, params)
              expect(form.valid?).to eq true
            end
          end
        end
      end
    end
  end

  describe "#save" do
    it "saves the params" do
      follow_up = create(:state_file_nc1099_r_followup)
      params = {
        income_source: "bailey_settlement",
        bailey_settlement_at_least_five_years: "yes",
        bailey_settlement_from_retirement_plan: "yes",
        uniformed_services_retired: "no",
        uniformed_services_qualifying_plan: "no",
      }

      form = described_class.new(follow_up, params)
      form.save

      expect(follow_up.income_source).to eq "bailey_settlement"
      expect(follow_up.bailey_settlement_at_least_five_years).to eq "yes"
      expect(follow_up.bailey_settlement_from_retirement_plan).to eq "yes"
      expect(follow_up.uniformed_services_retired).to eq "no"
      expect(follow_up.uniformed_services_qualifying_plan).to eq "no"
    end
  end
end
