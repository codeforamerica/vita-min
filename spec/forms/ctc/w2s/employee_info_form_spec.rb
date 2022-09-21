require 'rails_helper'

describe Ctc::W2s::EmployeeInfoForm do
  let(:w2) { create :w2, intake: intake }
  let(:intake) { create :ctc_intake }

  context "validations" do
    it "requires employee" do
      form = described_class.new(w2, {})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:employee)
    end

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

    it "requires city, state, and zip code" do
      form = described_class.new(w2, {})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:employee_city)
      expect(form.errors.attribute_names).to include(:employee_state)
      expect(form.errors.attribute_names).to include(:employee_zip_code)
    end

    it "must have a city with valid characters" do
      form = described_class.new(w2, { employee_city: 'Hamster-Wheel' })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:employee_city)
    end

    it "must have a state with valid characters" do
      form = described_class.new(w2, { employee_state: 'NotAState' })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:employee_state)
    end

    it "must have a zip code in the valid format" do
      form = described_class.new(w2, { employee_zip_code: 'RUTABAGA' })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:employee_zip_code)

      form = described_class.new(w2, { employee_zip_code: '94110' })
      form.valid?
      expect(form.errors.attribute_names).not_to include(:employee_zip_code)
    end
  end
end
