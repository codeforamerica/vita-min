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

    it "requires street address, city, state, and zip code" do
      form = described_class.new(w2, {})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:employee_street_address)
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
