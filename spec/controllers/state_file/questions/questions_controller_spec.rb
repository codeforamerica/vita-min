require "rails_helper"

RSpec.describe StateFile::Questions::QuestionsController do
  describe "#state_code" do
    it "returns the state code from the params if valid" do
      controller.params[:us_state] = "az"

      expect(subject.state_code).to eq "az"
    end

    it "raises an error when the state code is invalid" do
      controller.params[:us_state] = "na"

      expect do
        subject.state_code
      end.to raise_error(StandardError, "na")
    end
  end

  describe "#state_name" do
    it "returns the state name from the information service based on state_code" do
      allow(subject).to receive(:state_code).and_return "az"
      allow(StateFile::StateInformationService).to receive(:state_name).with("az").and_return "Arizona"

      expect(subject.state_name).to eq "Arizona"
    end
  end
end
