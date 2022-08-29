require 'rails_helper'

describe Ctc::W2s::EmployerInfoForm do
  let(:w2) { create :w2, intake: intake }
  let(:intake) { create :ctc_intake }

  context "validations" do
    it "requires ein in the valid format" do
      form = described_class.new(w2, {})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:employer_ein)

      form = described_class.new(w2, { employer_ein: 'RUTABAGA' })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:employer_ein)

      form = described_class.new(w2, { employer_ein: '12-3445678' })
      form.valid?
      expect(form.errors.attribute_names).not_to include(:employer_ein)

      form = described_class.new(w2, { employer_ein: '123445678' })
      form.valid?
      expect(form.errors.attribute_names).not_to include(:employer_ein)
    end
    
    it "requires name" do
      form = described_class.new(w2, {})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:employer_name)
    end

    it "requires city, state, and zip code" do
      form = described_class.new(w2, {})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:employer_city)
      expect(form.errors.attribute_names).to include(:employer_state)
      expect(form.errors.attribute_names).to include(:employer_zip_code)
    end

    it "must have a city with valid characters" do
      form = described_class.new(w2, { employer_city: 'Hamster-Wheel' })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:employer_city)
    end

    it "must have a state with valid characters" do
      form = described_class.new(w2, { employer_state: 'NotAState' })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:employer_state)
    end

    it "must have a zip code in the valid format" do
      form = described_class.new(w2, { employer_zip_code: 'RUTABAGA' })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:employer_zip_code)

      form = described_class.new(w2, { employer_zip_code: '94110' })
      form.valid?
      expect(form.errors.attribute_names).not_to include(:employer_zip_code)
    end

    it "must have standard_or_non_standard code set appropriately" do
      form = described_class.new(w2, { standard_or_non_standard_code: 'RUTABAGA' })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:standard_or_non_standard_code)

      form = described_class.new(w2, { standard_or_non_standard_code: 'S' })
      form.valid?
      expect(form.errors.attribute_names).not_to include(:standard_or_non_standard_code)
    end
  end
end
