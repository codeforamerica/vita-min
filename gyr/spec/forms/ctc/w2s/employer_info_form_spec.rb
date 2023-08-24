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

    it "requires street address, city, state, and zip code" do
      form = described_class.new(w2, {})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:employer_street_address)
      expect(form.errors.attribute_names).to include(:employer_city)
      expect(form.errors.attribute_names).to include(:employer_state)
      expect(form.errors.attribute_names).to include(:employer_zip_code)
    end

    it "must have a valid business name" do
      form = described_class.new(w2, { employer_name: 'Ca$h Møney B@by' })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:employer_name)
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

    it "does not require box_d_control_number but if present it can have a max of 14 characters" do
      form = described_class.new(w2, {})
      form.valid?
      expect(form.errors.attribute_names).not_to include(:box_d_control_number)

      form = described_class.new(w2, { box_d_control_number: 'a' * 15 })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box_d_control_number)
    end
  end
end
