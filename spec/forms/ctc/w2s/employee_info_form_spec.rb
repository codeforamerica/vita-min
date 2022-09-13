require 'rails_helper'

describe Ctc::W2s::EmployeeInfoForm do
  let(:w2) { create :w2, intake: intake }
  let(:intake) { create :ctc_intake }

  context "validations" do
    it "requires first and last name" do
      form = described_class.new(w2, {})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:legal_first_name)
      expect(form.errors.attribute_names).to include(:legal_last_name)
    end

    it "requires social security number to be present and formatted correctly" do
      form = described_class.new(w2, {})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:employee_ssn)

      form = described_class.new(w2, { employee_ssn: '111' })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:employee_ssn)
    end

    describe 'ssn confirmation' do
      it "is not valid if ssn is being changed and confirmation is missing" do
        form = described_class.new(w2, { employee_ssn: '111-22-3333' })
        expect(form).not_to be_valid
        expect(form.errors.attribute_names).to include(:employee_ssn_confirmation)
      end

      it "is not valid if ssn is being changed and confirmation does not match" do
        form = described_class.new(w2, { employee_ssn: '111-22-3333', employee_ssn_confirmation: '111-22-4444' })
        expect(form).not_to be_valid
        expect(form.errors.attribute_names).to include(:employee_ssn_confirmation)
      end

      it "is valid if ssn is being changed and confirmation matches" do
        form = described_class.new(w2, { employee_ssn: '111-22-3333', employee_ssn_confirmation: '111-22-3333' })
        form.valid?
        expect(form.errors.attribute_names).not_to include(:employee_ssn_confirmation)
      end

      it "does not require ssn confirmation if ssn is not being changed" do
        formatted_ssn = "#{w2.employee_ssn[0..2]}-#{w2.employee_ssn[3..4]}-#{w2.employee_ssn[5..8]}"
        form = described_class.new(w2, { employee_ssn: formatted_ssn })
        form.valid?
        expect(form.errors.attribute_names).not_to include(:employee_ssn_confirmation)
      end
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
