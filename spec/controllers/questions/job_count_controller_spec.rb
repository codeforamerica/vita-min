require "rails_helper"

RSpec.describe Questions::JobCountController do
  let(:intake) { create :intake }

  describe "#edit" do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :edit
    it_behaves_like :a_get_action_redirects_for_show_still_needs_help_clients, action: :edit
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          job_count_form: {
            job_count: "3"
          }
        }
      end

      before do
        allow(subject).to receive(:send_mixpanel_event).and_return(true)
      end

      it_behaves_like :a_post_action_for_authenticated_clients_only, action: :update

      context "as an authenticated client" do
        before { sign_in intake.client }

        it "saves data to the model" do
          post :update, params: params

          expect(intake.reload.job_count).to eq 3
        end

        it "calls send_mixpanel_event with the right data" do
          post :update, params: params

          expect(subject).to have_received(:send_mixpanel_event).with(event_name: "question_answered", data: { job_count: "3" })
        end
      end
    end
  end
end

