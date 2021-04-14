require "rails_helper"

describe TriageEligibilityForm do
  subject { described_class.new(params) }

  let(:had_farm_income) { "no" }
  let(:income_over_limit) { "no" }
  let(:had_rental_income) { "no" }
  let(:params) do
    {
      had_rental_income: had_rental_income,
      income_over_limit: income_over_limit,
      had_farm_income: had_farm_income
    }
  end

  context "an instance" do
    it 'responds to #had_farm_income' do
      expect(subject).to respond_to :had_farm_income
    end

    it "responds to #had_rental_income" do
      expect(subject).to respond_to :had_rental_income
    end

    it "responds to #income_over_limit" do
      expect(subject).to respond_to :income_over_limit
    end
  end

  describe "eligible?" do
    context "when all attributes are no" do
      it "is true" do
        expect(subject.eligible?).to eq true
      end
    end

    context "when had_rental_income is yes" do
      let(:had_rental_income) { "yes" }
      it "is false" do
        expect(subject.eligible?).to eq false
      end
    end

    context "when income_over_limit is yes" do
      let(:income_over_limit) { "yes" }
      it "is false" do
        expect(subject.eligible?).to eq false
      end
    end

    context "when had_farm_income is yes" do
      let(:had_farm_income) { "yes" }
      it "is false" do
        expect(subject.eligible?).to eq false
      end
    end
  end
end