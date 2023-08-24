require "rails_helper"

describe "fraud_indicators:update" do
  include_context "rake"

  let(:encrypted_indicators) do
    [{ "name"=>"pretend_indicator",
       "indicator_type"=>"gem",
       "query_model_name"=>"Intake",
       "threshold"=>nil,
       "reference"=>"intake",
       "list_model_name"=>nil,
       "indicator_attributes"=>%w[attribute1 attribute2 attribute3],
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

  context "with the same indicator name but different attributes" do
    let!(:existing_indicator) do
      create(:fraud_indicator,
             name: "pretend_indicator",
             indicator_type: "gem",
             query_model_name: "Intake",
             threshold: nil,
             reference: "intake",
             list_model_name: nil,
             indicator_attributes: %w[attribute1 attribute2 attribute3],
             points: 30, #this is the only line that is being changed
             multiplier: 0,
             description: nil
      )
    end

    it "does not create a new indicator" do
      expect { task.invoke }.to change { Fraud::Indicator.count }.by(0)
    end

    it "updates the existing indicator" do
      expect { task.invoke }.to change { Fraud::Indicator.last.points }.from(30).to(10)
    end

    it "does not update the activated_at" do
      expect { task.invoke }.not_to change { Fraud::Indicator.last.activated_at }
    end
  end
end

describe "fraud_indicators:preview_updates" do
  include_context "rake"

  let(:encrypted_indicators) do
    [{ "name"=>"pretend_indicator",
       "indicator_type"=>"gem",
       "query_model_name"=>"Intake",
       "threshold"=>nil,
       "reference"=>"intake",
       "list_model_name"=>nil,
       "indicator_attributes"=>%w[attribute1 attribute2 attribute3],
       "points"=>10,
       "multiplier"=>0,
       "description"=>nil
     }]
  end

  before do
    allow(JSON).to receive(:parse).and_return encrypted_indicators
    allow(Rails.logger).to receive(:info)
  end

  context "with a new fraud indicator in the encrypted file" do
    it "does not create a new indicator" do
      expect { task.invoke }.to change { Fraud::Indicator.count }.by(0)
    end

    it "outputs the expected changes" do
      expected_output = {"description"=>nil, "indicator_attributes"=>["attribute1", "attribute2", "attribute3"], "indicator_type"=>"gem", "list_model_name"=>nil, "multiplier"=>0.0, "name"=>"pretend_indicator", "points"=>10, "query_model_name"=>"Intake", "reference"=>"intake", "threshold"=>nil}
      task.invoke
      expect(Rails.logger).to have_received(:info).with("adds: #{expected_output}")
    end
  end

  context "with the same indicator name but different attributes" do
    let!(:existing_indicator) do
      create(:fraud_indicator,
             name: "pretend_indicator",
             indicator_type: "gem",
             query_model_name: "Intake",
             threshold: nil,
             reference: "intake",
             list_model_name: nil,
             indicator_attributes: %w[attribute1 attribute2 attribute3],
             points: 30, #this is the only line that is being changed
             multiplier: 0,
             description: nil
      )
    end

    it "does not update the indicator" do
      expect { task.invoke }.not_to change { Fraud::Indicator.last.points }
    end

    it "outputs the expected changes" do
      expected_output = {"points" => [30, 10]}
      task.invoke
      expect(Rails.logger).to have_received(:info).with("updates: #{expected_output}")
    end
  end

  context "with no changes" do
    let!(:existing_indicator) do
      create(:fraud_indicator,
             name: "pretend_indicator",
             indicator_type: "gem",
             query_model_name: "Intake",
             threshold: nil,
             reference: "intake",
             list_model_name: nil,
             indicator_attributes: %w[attribute1 attribute2 attribute3],
             points: 10,
             multiplier: 0,
             description: nil
      )
    end

    it "does not update the indicator" do
      expect { task.invoke }.not_to change { Fraud::Indicator.last.points }
    end

    it "outputs nothing" do
      expect(Rails.logger).not_to have_received(:info)
    end
  end
end
