require "rails_helper"

RSpec.describe TriageBacktaxesYearsForm do
  describe "#save" do
    context "with valid params" do
      let(:params) do
        {
          filed_2018: "no",
          filed_2019: "no",
          filed_2020: "no",
          filed_2021: "yes",
        }
      end

      let(:triage) do
        create(:triage)
      end

      it "saves the data" do
        described_class.new(triage, params).save
        triage.reload

        expect(triage.filed_2018).to eq "no"
        expect(triage.filed_2019).to eq "no"
        expect(triage.filed_2020).to eq "no"
        expect(triage.filed_2021).to eq "yes"
      end
    end
  end
end
