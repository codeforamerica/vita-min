require "rails_helper"

RSpec.describe TriageIncomeTypesForm do
  let(:triage) do
    create(:triage)
  end

  describe "validation" do
    let(:params) { {} }

    it "requires an income_* value" do
      form = described_class.new(triage, params)
      expect(form).not_to be_valid
      expect(form.errors).to include(:none_of_the_above)
    end

    context "when both 'none' and any other value is selected" do
      let(:params) do
        {
          income_type_rent: "no",
          income_type_farm: "yes",
          none_of_the_above: "yes"
        }
      end

      it "shows a validation error" do
        form = described_class.new(triage, params)
        expect(form).not_to be_valid
        expect(form.errors).to include(:none_of_the_above)
      end
    end
  end

  describe "#save" do
    context "with valid params" do
      let(:params) do
        {
          income_type_rent: "no",
          income_type_farm: "yes",
          none_of_the_above: "no"
        }
      end

      it "saves the data" do
        described_class.new(triage, params).save
        triage.reload

        expect(triage.income_type_rent).to eq "no"
        expect(triage.income_type_farm).to eq "yes"
      end
    end
  end
end
