require "rails_helper"

RSpec.describe Questions::EligibilityHouseholdController, type: :controller do
  describe "#next_path" do
    let(:intake) { create :intake }
    let(:triage_result_service) { instance_double(TriageResultService) }

    before do
      allow(controller).to receive(:current_intake).and_return(intake)

      allow(TriageResultService).to receive(:new).with(intake).and_return(triage_result_service)
    end

    context "when the triage service returns a path" do
      let(:simple_file_url) do
        "https://staging.simplefile.getyourrefund.org/en/service-selection/recommendation/simplefile"
      end

      before do
        allow(triage_result_service).to receive(:after_household_triaged_route).and_return(simple_file_url)
      end

      it "returns the triage service path" do
        expect(controller.next_path).to eq(simple_file_url)
      end
    end

    context "when the triage service does not return a path" do
      before do
        allow(triage_result_service).to receive(:after_household_triaged_route).and_return(nil)

        allow_any_instance_of(Questions::QuestionsController).to receive(:next_path).and_return("/en/questions/next-question")
      end

      it "falls back to the parent controller next path" do
        expect(controller.next_path).to eq("/en/questions/next-question")
      end
    end
  end

  describe "#allow_other_host_redirect?" do
    it "allows redirects to another host" do
      result = controller.send(:allow_other_host_redirect?)
      expect(result).to be(true)
    end
  end
end