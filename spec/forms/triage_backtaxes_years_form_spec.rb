require "rails_helper"

RSpec.describe TriageBacktaxesYearsForm do
  describe "#save" do
    context "with valid params" do
      let(:params) do
        {
          backtaxes_2018: "no",
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
