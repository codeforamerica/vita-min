require "rails_helper"

RSpec.describe StateFile::StateFileControllerConcern, type: :controller do
  controller(ApplicationController) do
    include StateFile::StateFileControllerConcern
  end

  describe "#state_code" do
    it "returns the state code from the params if valid" do
      controller.params[:us_state] = "az"

      expect(controller.state_code).to eq "az"
    end

    it "raises an error when the state code is invalid" do
      controller.params[:us_state] = "na"

      expect do
        controller.state_code
      end.to raise_error(StandardError, "na")
    end
  end

  describe "#state_name" do
    it "returns the state name from the information service based on state_code" do
      allow(controller).to receive(:state_code).and_return "az"
      allow(StateFile::StateInformationService).to receive(:state_name).with("az").and_return "Arizona"

      expect(controller.state_name).to eq "Arizona"
    end
  end
end
