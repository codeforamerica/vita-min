require "rails_helper"

RSpec.describe TriageAssistanceForm do
  let(:triage) do
    create(:triage)
  end

  describe "validation" do
    let(:params) { {} }

    it "requires an assistance_* value" do
      form = described_class.new(triage, params)
      expect(form).not_to be_valid
      expect(form.errors).to include(:assistance_none)
    end

    context "when both 'none' and any other value is selected" do
      let(:params) do
        {
          assistance_in_person: "no",
          assistance_phone_review_english: "yes",
          assistance_phone_review_non_english: "no",
          assistance_none: "yes"
        }
      end

      it "shows a validation error" do
        form = described_class.new(triage, params)
        expect(form).not_to be_valid
        expect(form.errors).to include(:assistance_none)
      end
    end
  end

  describe "#save" do
    context "with valid params" do
      let(:params) do
        {
          assistance_in_person: "no",
          assistance_phone_review_english: "no",
          assistance_phone_review_non_english: "no",
          assistance_none: "no"
        }
      end

      it "saves the data" do
        described_class.new(triage, params).save
        triage.reload

        expect(triage.assistance_in_person).to eq "no"
        expect(triage.assistance_phone_review_english).to eq "no"
        expect(triage.assistance_phone_review_non_english).to eq "no"
      end
    end
  end
end
