require 'rails_helper'

describe Ctc::W2s::WagesInfoForm do
  let(:w2) { create :w2, intake: intake }
  let(:intake) { create :ctc_intake }

  context "validations" do
    it "requires wages to be present and look like money" do
      form = described_class.new(w2, {})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:wages_amount)

      form = described_class.new(w2, { wages_amount: 'RUTABAGA'})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:wages_amount)
    end

    it "requires federal_income_tax_withheld to be present and look like money" do
      form = described_class.new(w2, {})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:federal_income_tax_withheld)

      form = described_class.new(w2, { federal_income_tax_withheld: 'RUTABAGA'})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:federal_income_tax_withheld)
    end
  end
end
