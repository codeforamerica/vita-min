require 'rails_helper'

describe Ctc::Dependents::InfoForm do
  let(:intake) { create :ctc_intake }
  let(:dependent) { create :dependent, intake: intake, first_name: nil, last_name: nil, relationship: nil, birth_date: nil }

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
  
  describe '#save' do
    let(:intake) { build(:ctc_intake) }
    let(:params) do
      {
        first_name: 'Fae',
        last_name: 'Taxseason',
        suffix: 'Jr',
        birth_date_day: 1,
        birth_date_month: 1,
        birth_date_year: 1.year.ago.year,
        relationship: "daughter",
        full_time_student: "no",
        permanently_totally_disabled: "no"
      }
    end

    it "saves the attributes on the dependent" do
      form = described_class.new(dependent, params)
      expect(form.save).to be_truthy

      dependent = Dependent.last
      expect(dependent.first_name).to eq "Fae"
      expect(dependent.last_name).to eq "Taxseason"
      expect(dependent.suffix).to eq "Jr"
    end
  end
end
