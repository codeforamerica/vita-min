require "rails_helper"

describe Dependent::Rules do
  let(:tax_year) { 2020 }
  let(:full_time_student_yes) { false }
  let(:permanently_totally_disabled_yes) { false }
  let(:subject) { described_class.new(birth_date, tax_year, full_time_student_yes, permanently_totally_disabled_yes) }

  context ".born_in_last_6_months?" do
    context "when born on Jan 1" do
      let(:birth_date) { Date.new(tax_year, 1, 1) }

      it "is false" do
        expect(subject.born_in_last_6_months?).to be_falsey
      end
    end

    context "when born on June 30" do
      let(:birth_date) { Date.new(tax_year, 6, 30) }

      it "is true" do
        expect(subject.born_in_last_6_months?).to be_truthy
      end
    end

    context "when born on June 30" do
      let(:birth_date) { Date.new(tax_year, 6, 30) }

      it "is true" do
        expect(subject.born_in_last_6_months?).to be_truthy
      end
    end
  end

  context ".age" do
    context "when born on Jan 1 of the tax year" do
      let(:birth_date) { Date.new(tax_year, 1, 1) }

      it "is 0" do
        expect(subject.age).to eq(0)
      end
    end

    context "when born on Dec 31 of the previous year" do
      let(:birth_date) { Date.new(tax_year - 1, 12, 1) }

      it "is 1" do
        expect(subject.age).to eq(1)
      end
    end
  end

  describe ".meets_qc_age_condition?" do
    context "with a dependent that is under 19" do
      let(:birth_date) { Date.new(tax_year - 5, 12, 25) }

      it "returns true" do
        expect(subject.meets_qc_age_condition?).to eq true
      end
    end

    context "with a dependent that is between 19 and 24 and a full time student" do
      let(:full_time_student_yes) { true }
      let(:birth_date) { Date.new(tax_year - 20, 12, 25) }

      it "returns true" do
        expect(subject.meets_qc_age_condition?).to eq true
      end
    end

    context "with a dependent that is over 24 but disabled" do
      let(:permanently_totally_disabled_yes) { true }
      let(:birth_date) { Date.new(tax_year - 40, 12, 25) }

      it "returns true" do
        expect(subject.meets_qc_age_condition?).to eq true
      end
    end

    context "with a dependent that is over 19 and not a student, not disabled" do
      let(:birth_date) { Date.new(tax_year - 20, 12, 25) }

      it "returns false" do
        expect(subject.meets_qc_age_condition?).to eq false
      end
    end
  end
end
