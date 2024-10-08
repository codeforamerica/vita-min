require 'rails_helper'

describe Efile::Nc::D400ScheduleSCalculator do
  let(:intake) { create(:state_file_nc_intake) }
  let!(:d400_calculator) do
    Efile::Nc::D400Calculator.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end
  let(:instance) { d400_calculator.instance_variable_get(:@d400_schedule_s) }

  describe 'Line 27: Exempt Income Earned or Received by a Member of a Federally Recognized Indian Tribe' do
    context "if there are not tribal wages from intake" do
      it "returns 0 for line 27 and line 41" do
        d400_calculator.calculate
        expect(instance.lines[:NCD400_S_LINE_27]&.value).to eq(0)
        expect(instance.lines[:NCD400_S_LINE_41]&.value).to eq(0)
      end
    end

    context 'if there are tribal wages from intake' do
      before do
        intake.tribal_member = "yes"
        intake.tribal_wages_amount = 500.00
      end

      it 'returns the tribal wages amount from the intake' do
        d400_calculator.calculate
        expect(instance.lines[:NCD400_S_LINE_27]&.value).to eq(500)
      end

      it 'includes the tribal wages amount in line 41' do
        d400_calculator.calculate
        expect(instance.lines[:NCD400_S_LINE_41]&.value).to eq(500)
      end
    end
  end
end