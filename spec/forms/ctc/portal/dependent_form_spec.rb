require "rails_helper"

describe Ctc::Portal::DependentForm do
  let(:dependent) { create :dependent, birth_date: Date.new(2020, 1, 2) }
  describe "#initialize" do
    it "uses the dependent age from the DB in favor of year from params" do
      form = described_class.new(dependent, { birth_date_year: 2021, birth_date_month: 2, birth_date_day: 3 })
      expect(form.birth_date_year).to eq 2020
      expect(form.birth_date_month).to eq 2
      expect(form.birth_date_day).to eq 3
    end
  end
end
