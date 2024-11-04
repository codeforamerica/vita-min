require 'rails_helper'

describe Efile::Id::Id39RCalculator do
  let(:intake) { create(:state_file_id_intake) }
  let(:id40_calculator) do
    Efile::Id::Id40Calculator.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end
  let(:instance) { id40_calculator.instance_variable_get(:@id39r) }

  describe "Section B Line 3: Interest on Government Bonds" do
    context "when there are interest reports with government bonds" do
      let(:intake) {
        create(:state_file_id_intake, :df_data_1099_int)
      }
      it "sums the interest from government bonds across all reports" do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_3].value).to eq(2)
      end
    end

    context "when there are no interest reports" do
      it "returns 0" do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_3].value).to eq(0)
      end
    end
  end

  describe "Section B Line 18: Health Insurance Premium" do
    context "when there are health insurance premiums" do
      before do
        intake.update(has_health_insurance_premium: "yes", health_insurance_paid_amount: 12.55)
      end
      it "sums the interest from government bonds across all reports" do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_18].value).to eq(13)
      end
    end

    context "when there are no health insurance premiums" do
      it "returns 0" do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_18].value).to eq(0)
      end
    end
  end
end