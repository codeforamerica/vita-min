require 'rails_helper'

describe Efile::Az::Az322Calculator do
  let(:intake) { create(:state_file_az_intake) }
  let(:main_calculator) do
    Efile::Az::Az140Calculator.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end
  let(:instance) { main_calculator.instance_variable_get(:@az322) }

  describe "line 5" do
    it "rounds the amounts before summing them" do
      create_list(:az322_contribution, 3, state_file_az_intake: intake, amount: 10.40)
      intake.reload
      instance.calculate
      expect(instance.lines[:AZ322_LINE_5].value).to eq(30)
    end
  end
end
