require 'rails_helper'

RSpec.describe StateFile::AzRetirementIncomeSubtractionForm, type: :model do
  describe "validations" do
    it { should validate_presence_of :income_source }
  end

  describe "#save" do
    it "saves the params" do
      follow_up = create(:state_file_az1099_r_followup)
      params = {
        income_source: "uniformed_services",
      }

      form = described_class.new(follow_up, params)
      form.save

      expect(follow_up.income_source).to eq "uniformed_services"
    end
  end
end
