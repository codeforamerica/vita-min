require 'rails_helper'

RSpec.describe StateFile::IdRetirementAndPensionIncomeForm, type: :model do
  describe "validations" do
    it { should validate_presence_of :eligible_income_source }
  end

  describe "#save" do
    it "saves the params" do
      follow_up = create(:state_file_id1099_r_followup)
      params = {
        eligible_income_source: "yes",
      }

      form = described_class.new(follow_up, params)
      form.save

      expect(follow_up.eligible_income_source).to eq "yes"
    end
  end
end

