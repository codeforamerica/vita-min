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

    context "with the variable --preview" do
      before do
        ARGV.replace ["fraud_indicators:update", "--preview"]
      end

      it "does not create a new indicator" do
        expect { task.invoke }.to change { Fraud::Indicator.count }.by(0)
      end

      it "outputs the expected changes" do
        expected_output = {"description"=>nil, "indicator_attributes"=>["attribute1", "attribute2", "attribute3"], "indicator_type"=>"gem", "list_model_name"=>nil, "multiplier"=>0.0, "name"=>"pretend_indicator", "points"=>10, "query_model_name"=>"Intake", "reference"=>"intake", "threshold"=>nil}
        expect { task.invoke }.to output("adds: #{expected_output}").to_stdout
      end
    end
  end

  context "with the same indicator name but different attributes" do
    let!(:existing_indicator) { create(:fraud_indicator, name: "pretend_indicator", points: 30) }

    it "does not create a new indicator" do
      expect { task.invoke }.to change { Fraud::Indicator.count }.by(0)
    end

    it "updates the existing indicator" do
      expect { task.invoke }.to change { Fraud::Indicator.last.points }.from(30).to(10)
    end

    it "does not update the activated_at" do
      expect { task.invoke }.not_to change { Fraud::Indicator.last.activated_at }
    end

    context "with the variable --preview" do
      before do
        ARGV.replace ["fraud_indicators:update", "--preview"]
      end

      it "does not update the indicator" do
        expect { task.invoke }.not_to change { Fraud::Indicator.last.points }
      end

      it "outputs the expected changes" do
        expect { task.invoke }.to output('updates: { points => 10 }').to_stdout
      end
    end
  end
end