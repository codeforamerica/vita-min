require 'rails_helper'

describe Ctc::Dependents::InfoForm do
  context "validations" do
    it "requires first and last name" do
      form = described_class.new
      expect(form).not_to be_valid
      expect(form.errors.keys).to include(:first_name)
      expect(form.errors.keys).to include(:last_name)
    end

    it "requires relationship" do
      form = described_class.new
      expect(form).not_to be_valid
      expect(form.errors.keys).to include(:relationship)
    end

    it "requires birth date" do
      form = described_class.new
      expect(form).not_to be_valid
      expect(form.errors.keys).to include(:birth_date)

      form.assign_attributes(birth_date_month: '1', birth_date_day: '1', birth_date_year: 1.year.ago.year.to_s)
      form.valid?
      expect(form.errors.keys).not_to include(:birth_date)
    end
  end
end
