require "rails_helper"

describe Dependent::Rules do
  let(:tax_year) { 2020 }

  context ".born_in_last_6_months?" do
    let(:subject) { described_class.new(birth_date, tax_year) }
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
    let(:subject) { described_class.new(birth_date, tax_year) }

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
end
