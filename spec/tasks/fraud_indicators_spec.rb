require "rails_helper"

describe "fraud_indicators:add" do
  include_context "rake"

  let(:encrypted_indicators) do
    [{ "name"=>"pretend_indicator",
       "indicator_type"=>"gem",
       "query_model_name"=>"Intake",
       "threshold"=>nil,
       "reference"=>"intake",
       "list_model_name"=>nil,
       "indicator_attributes"=>["attribute1"],
       "points"=>10,
       "multiplier"=>0,
       "description"=>nil
     }]
  end

  before do
    allow(JSON).to receive(:parse).and_return encrypted_indicators
  end

  context "with a new fraud indicator in the encrypted file" do
    it "adds it to the database" do
      expect { task.invoke }.to change { Fraud::Indicator.count }.by(1)
      expect(Fraud::Indicator.last.name).to eq "pretend_indicator"
    end
  end

  context "with no new indicators" do
    let!(:existing_indicator) { create(:fraud_indicator, name: "pretend_indicator") }

    it "does not update the database" do
      expect { task.invoke }.to change { Fraud::Indicator.count }.by(0)
    end
  end
end