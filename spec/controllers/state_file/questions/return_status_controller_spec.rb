require "rails_helper"

RSpec.describe StateFile::Questions::ReturnStatusController do
  describe "#edit" do
    context "AZ" do
      render_views
      let(:az_intake) { create :state_file_az_intake }
      before do
        sign_in az_intake
      end

      context "happy path" do
        let!(:efile_submission) { create(:efile_submission, :notified_of_rejection, :for_state, data_source: az_intake) }

        it "shows the most recent submission" do
          get :edit, params: { us_state: "az" }

          expect(assigns(:submission_to_show)).to eq efile_submission
        end
      end

      context "unhappy path" do
        let!(:previous_efile_submission) { create(:efile_submission, :accepted, :for_state, data_source: az_intake) }
        let!(:latest_efile_submission) { create(:efile_submission, :transmitted, :for_state, data_source: az_intake) }

        before do
          latest_efile_submission.transition_to!(:rejected)
          create(:efile_submission_transition_error, efile_error: efile_error, efile_submission_transition: latest_efile_submission.last_transition, efile_submission_id: latest_efile_submission.id)
          latest_efile_submission.transition_to!(:cancelled)
        end

        context "client got accepted and then submitted another return which got reject 901" do
          let(:efile_error) { create(:efile_error, code: "901", service_type: :state_file, expose: true) }

          it "shows the most recent accepted submission" do
            get :edit, params: { us_state: "az" }

            expect(assigns(:submission_to_show)).to eq previous_efile_submission
          end
        end

        context "client got accepted and then submitted another return which got a different rejection" do
          let(:efile_error) { create(:efile_error, code: "A LEGIT REJECTION I GUESS", service_type: :state_file, expose: true) }

          it "shows the most recent submission" do
            get :edit, params: { us_state: "az" }

            expect(assigns(:submission_to_show)).to eq latest_efile_submission
          end
        end
      end
    end

    context "NY" do
      let(:ny_intake) { create :state_file_ny_intake }
      before do
        sign_in ny_intake
      end

      context "happy path" do
        let!(:efile_submission) { create(:efile_submission, :notified_of_rejection, :for_state, data_source: ny_intake) }

        it "shows the most recent submission" do
          get :edit, params: { us_state: "ny" }

          expect(assigns(:submission_to_show)).to eq efile_submission
        end
      end
    end
  end
end