require "rails_helper"

RSpec.describe StateFile::StateFileControllerConcern, type: :controller do
  controller(ApplicationController) do
    include StateFile::StateFileControllerConcern

    def index
      head :ok
    end
  end

  describe "helper methods" do
    let(:az_intake) { create(:state_file_az_intake) }

    describe "#current_intake" do
      context "when there is a logged in intake" do
        before { sign_in az_intake }

        it "returns that intake" do
          expect(subject.current_intake).to eq az_intake
        end

        context "when there are multiple logged in intakes" do
          before { sign_in create(:state_file_md_intake) }

          it "returns the first logged in intake it can find" do
            expect(subject.current_intake).to eq az_intake
          end
        end
      end

      context "when there is not a logged in intake" do
        it "returns nil" do
          expect(subject.current_intake).to be_nil
        end
      end
    end
  end
end
