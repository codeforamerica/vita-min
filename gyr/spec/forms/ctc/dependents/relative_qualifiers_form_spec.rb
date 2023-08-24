require "rails_helper"

describe Ctc::Dependents::RelativeQualifiersForm do
  describe "#save" do
    let(:intake) { create :ctc_intake }
    let(:dependent) { create :dependent, intake: intake }
    let(:cant_be_claimed_by_other) { "yes" }
    let(:below_qualifying_relative_income_requirement) { "yes" }
    let(:none_of_the_above) { "no" }
    let(:params) do
      {
          cant_be_claimed_by_other: cant_be_claimed_by_other,
          below_qualifying_relative_income_requirement: below_qualifying_relative_income_requirement,
          none_of_the_above: none_of_the_above
      }
    end

    it "saves the relative qualifies fields on the dependent" do
      expect {
        form = described_class.new(dependent, params)
        form.save
      }.to change(dependent, :cant_be_claimed_by_other).to("yes")
               .and change(dependent, :below_qualifying_relative_income_requirement).to("yes")
    end

    context "when no items are checked" do
      let(:cant_be_claimed_by_other) { "no" }
      let(:below_qualifying_relative_income_requirement) { "no" }
      let(:none_of_the_above) { "no" }
      it "is not valid" do
        form = described_class.new(dependent, params)
        expect(form).not_to be_valid
        expect(form.errors[:none_of_the_above]).not_to be_blank
      end
    end

    context "when none of the above is selected item" do
      let(:cant_be_claimed_by_other) { "no" }
      let(:below_qualifying_relative_income_requirement) { "no" }
      let(:none_of_the_above) { "yes" }
      it "is valid" do
        form = described_class.new(dependent, params)
        expect(form).to be_valid
        expect(form.errors[:none_of_the_above]).to be_blank
      end
    end
  end
end