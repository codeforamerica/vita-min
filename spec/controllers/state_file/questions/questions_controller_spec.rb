require "rails_helper"

RSpec.describe StateFile::Questions::QuestionsController do
  describe "#current_state_code" do
    context "when there is a logged in intake" do
      it "returns the state code from the logged in intake" do
        intake = create(:state_file_az_intake)
        allow(subject).to receive(:current_intake).and_return(intake)

        expect(subject.current_state_code).to eq "az"
      end
    end

    context "when there is no logged in intake" do
      it "returns the state code from the params" do
        controller.params[:us_state] = "az"

        expect(subject.current_state_code).to eq "az"
      end
    end
  end

  describe "#current_state_name" do
    it "returns the state name from the information service based on current_state_code" do
      allow(subject).to receive(:current_state_code).and_return "az"
      allow(StateFile::StateInformationService).to receive(:state_name).with("az").and_return "Arizona"

      expect(subject.current_state_name).to eq "Arizona"
    end
  end
end
