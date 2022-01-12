require "rails_helper"

RSpec.describe TriageAssistanceForm do
  let(:triage) do
    create(:triage, assistance_in_person: nil, assistance_chat: nil, assistance_phone_review_english: nil, assistance_phone_review_non_english: nil, assistance_none: nil)
  end

  describe "validation" do
    let(:params) { {} }

    it "requires an assistance_* value" do
      form = described_class.new(triage, params)
      expect(form).not_to be_valid
      expect(form.errors).to include(:assistance_none)
    end
  end

  xdescribe "#save" do
    context "with valid params" do
      # TODO
      let(:params) do
        {
          assistance_in_person: "no",
          backtaxes_2019: "no",
          backtaxes_2020: "no",
          backtaxes_2021: "yes",
        }
      end

      let(:triage) do
        create(:triage, backtaxes_2018: nil, backtaxes_2019: nil, backtaxes_2020: nil, backtaxes_2021: nil)
      end

      it "saves the data" do
        described_class.new(triage, params).save
        triage.reload

        expect(triage.backtaxes_2018).to eq "no"
        expect(triage.backtaxes_2019).to eq "no"
        expect(triage.backtaxes_2020).to eq "no"
        expect(triage.backtaxes_2021).to eq "yes"
      end
    end
  end
end
