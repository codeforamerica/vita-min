require "rails_helper"

describe Hub::EfileErrorsController do
  let(:user) { create :admin_user }
  describe "#index" do
    it_behaves_like :an_action_for_admins_only , action: :index, method: :get

    context "as an authenticated user" do
      let!(:efile_error) { create :efile_error, code: "CANCEL-ME-123", service_type: :ctc }

      before do
        sign_in user
      end

      it "renders index" do
        get :index
        expect(response).to render_template :index
        expect(assigns(:efile_errors)).to match_array [efile_error]
      end
    end
  end

  describe "#edit" do
    let(:efile_error) { create :efile_error, service_type: :ctc }
    let(:params) { { id: efile_error.id } }

    it_behaves_like :an_action_for_admins_only , action: :edit, method: :get
    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "renders edit" do
        get :edit, params: params
        expect(assigns(:efile_error)).to eq efile_error
        expect(response).to render_template :edit
      end
    end
  end

  describe "#update" do
    let!(:efile_error) { create :efile_error, service_type: :ctc, expose: false }
    let(:params) do
      {
        id: efile_error.id,
        efile_error: {
          expose: true,
          service_type: :ctc,
          auto_cancel: true,
          auto_wait: true,
          description_en: "<div>We were unable to verify your address. Can you check to see if there are any mistakes?</div>",
          description_es: "<div>We were unable to verify your address. Can you check to see if there are any mistakes? (In spanish)</div>",
          resolution_en: "<div>Here's how you can fix it.</div>",
          resolution_es: "<div>Here's how you can fix it. (in spanish)</div>",
        }
      }
    end

    it_behaves_like :an_action_for_admins_only, action: :update, method: :put

    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "updates the object based on passed params" do
        expect(efile_error.expose).to eq false
        put :update, params: params
        efile_error.reload
        expect(efile_error.expose).to eq true
        expect(efile_error.auto_cancel).to eq true
        expect(efile_error.auto_wait).to eq true
        expect(efile_error.description_en.body).to be_an_instance_of ActionText::Content
        expect(efile_error.description_en.body.to_s).to include "<div>We were unable to verify your address. Can you check to see if there are any mistakes?</div>"
        expect(response).to redirect_to hub_efile_error_path(id: efile_error.id)
      end
    end
  end

  describe "#reprocess" do
    context "as an authenticated user" do
      let!(:transition_error) { create :efile_submission_transition_error, efile_error: wait_efile_error, efile_submission_transition: submission_to_transition.last_transition, efile_submission_id: submission_to_transition.id }
      let!(:failed_transition_error) { create :efile_submission_transition_error, efile_error: cancel_efile_error, efile_submission_transition: failed_submission.last_transition, efile_submission_id: failed_submission.id }

      let(:submission_to_transition) { create :efile_submission, :rejected }
      let(:cancelled_submission) { create :efile_submission, :cancelled }
      let(:failed_submission) { create :efile_submission, :failed }

      let(:wait_efile_error) { create :efile_error, code: "WAIT-ME-123", auto_wait: true, service_type: :ctc }
      let(:cancel_efile_error) { create :efile_error, code: "CANCEL-ME-123", auto_cancel: true, service_type: :ctc }

      let(:params) do
        {
          id: wait_efile_error.id,
        }
      end

      before do
        sign_in user
      end

      it "successfully transitions submissions in a rejected state to the auto-transition state on the error" do
        expect(submission_to_transition.current_state).to eq "rejected"
        patch :reprocess, params: params
        expect(submission_to_transition.current_state(force_reload: true)).to eq "waiting"

        expect(flash[:notice]).to eq("Successfully reprocessed 1 submission(s) with WAIT-ME-123 error!")
      end

      it "does not transition submissions in a non-failed/rejected state or those with a different error" do
        expect(cancelled_submission.current_state).to eq "cancelled"
        expect(failed_submission.current_state).to eq "failed"
        patch :reprocess, params: params
        expect(cancelled_submission.current_state(force_reload: true)).to eq "cancelled"
        expect(failed_submission.current_state(force_reload: true)).to eq "failed"
      end

      context "with no auto-transition on the error" do
        let(:do_nothing_error) { create :efile_error, code: "NOTHING-ME-123", auto_cancel: false, auto_wait: false, service_type: :ctc }

        let(:params) do
          {
            id: do_nothing_error.id,
          }
        end

        it "flashes a notice about not being able to process" do
          patch :reprocess, params: params
          expect(flash[:notice]).to eq("Could not reprocess NOTHING-ME-123. Try again.")
        end
      end
    end
  end
end
