require "rails_helper"

describe StateFile::StateInformationService do
  describe ".active_state_codes" do
    it "returns the list of state codes as strings" do
      expect(described_class.active_state_codes).to match_array ["az", "ny"]
    end
  end

  describe ".state_name" do
    it "returns the name of the state from states.yml" do
      expect(described_class.state_name("az")).to eq "Arizona"
    end

    it "throws an error for an invalid state code" do
      expect do
        described_class.state_name("boop")
      end.to raise_error(StandardError, "boop")
    end
  end

  describe ".state_code_to_name_map" do
    it "returns a map of all the state codes to state names" do
      result = {
        "az" => "Arizona",
        "ny" => "New York",
      }
      expect(described_class.state_code_to_name_map).to eq result
    end
  end

  describe ".state_code_from_intake_class" do
    it "returns the corresponding state code string given an intake class" do
      expect(described_class.state_code_from_intake_class(StateFileAzIntake)).to eq "az"
    end
  end
end