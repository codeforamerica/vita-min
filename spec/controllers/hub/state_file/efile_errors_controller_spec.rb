require "rails_helper"
describe Hub::StateFile::EfileErrorsController do
  let!(:state_file_admin) { create :state_file_admin_user }
  describe "#index" do
    let!(:efile_error) { create :efile_error, code: "CANCEL-ME-123", service_type: :state_file_ny }

    context "as an authenticated user" do
      before do
        sign_in state_file_admin
      end

      it "renders index" do
        get :index
        expect(response).to render_template :index
        expect(assigns(:efile_errors)).to match_array [efile_error]
      end
    end
  end

  describe "#edit" do
    let(:efile_error) { create :efile_error, service_type: :state_file_ny }
    let(:params) { { id: efile_error.id } }

    context "as an authenticated user" do
      before do
        sign_in state_file_admin
      end
      it "renders edit" do
        get :edit, params: params
        expect(assigns(:efile_error)).to eq efile_error
        expect(response).to render_template :edit
      end
    end
  end

  describe "#update" do
    let!(:efile_error) { create :efile_error, service_type: :state_file_ny, expose: false }
    let(:params) do
      {
        id: efile_error.id,
        efile_error: {
          expose: true,
          service_type: :state_file_ny,
          auto_cancel: true,
          auto_wait: true,
          description_en: "<div>We were unable to verify your address. Can you check to see if there are any mistakes?</div>",
          description_es: "<div>We were unable to verify your address. Can you check to see if there are any mistakes? (In spanish)</div>",
          resolution_en: "<div>Here's how you can fix it.</div>",
          resolution_es: "<div>Here's how you can fix it. (in spanish)</div>",
        }
      }
    end

    context "as an authenticated user" do
      before do
        sign_in state_file_admin
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
        expect(response).to redirect_to hub_state_file_efile_error_path(id: efile_error.id)
      end
    end
  end

  describe "#reprocess" do
    context "as an authenticated user" do
      let(:rejected_submission) { create :efile_submission, :for_state, :rejected }
      let(:cancelled_submission) { create :efile_submission, :for_state, :cancelled }
      let(:failed_submission) { create :efile_submission, :for_state, :failed }
      let(:wait_efile_error) { create :efile_error, code: "WAIT-ME-123", auto_wait: true, service_type: :state_file_ny }
      let(:cancel_efile_error) { create :efile_error, code: "CANCEL-ME-123", auto_cancel: true, service_type: :state_file_ny }
      let(:not_handled_error) { create :efile_error, code: "NOTHING-ME-123", auto_cancel: false, auto_wait: false, service_type: :state_file_ny }
      let(:params) do
        {
          id: wait_efile_error.id,
        }
      end
      before do
        sign_in state_file_admin
      end

      context "in rejected state" do
        context "with only auto_wait errors" do
          let!(:transition_error) { create :efile_submission_transition_error, efile_error: wait_efile_error, efile_submission_transition: rejected_submission.last_transition, efile_submission_id: rejected_submission.id }

          it "successfully transitions submissions in a rejected state to the auto-transition notified_of_rejection state on the error" do
            expect(rejected_submission.current_state).to eq "rejected"
            patch :reprocess, params: params
            expect(rejected_submission.current_state(force_reload: true)).to eq "notified_of_rejection"
            expect(flash[:notice]).to eq("Successfully reprocessed 1 submission(s) with WAIT-ME-123 error!")
          end
        end

        context "with auto_wait and unhandled error" do
          let!(:not_handled_transition_error) { create :efile_submission_transition_error, efile_error: not_handled_error, efile_submission_transition: rejected_submission.last_transition, efile_submission_id: rejected_submission.id }
          let!(:auto_wait_transition_error) { create :efile_submission_transition_error, efile_error: wait_efile_error, efile_submission_transition: rejected_submission.last_transition, efile_submission_id: rejected_submission.id }
          let(:params) do
            {
              id: wait_efile_error.id,
            }
          end

          it "successfully transitions submissions in a rejected state to the auto-transition waiting state on the error" do
            expect(rejected_submission.current_state).to eq "rejected"
            patch :reprocess, params: params
            expect(rejected_submission.current_state(force_reload: true)).to eq "waiting"
            expect(flash[:notice]).to eq("Successfully reprocessed 1 submission(s) with WAIT-ME-123 error!")
          end
        end

        context "with auto_cancel error" do
          let!(:transition_error) { create :efile_submission_transition_error, efile_error: cancel_efile_error, efile_submission_transition: rejected_submission.last_transition, efile_submission_id: rejected_submission.id }
          let(:params) do
            {
              id: cancel_efile_error.id,
            }
          end
          it "successfully transitions submissions in a rejected state to the auto-transition cancelled state on the error" do
            expect(rejected_submission.current_state).to eq "rejected"
            patch :reprocess, params: params
            expect(rejected_submission.current_state(force_reload: true)).to eq "cancelled"
            expect(flash[:notice]).to eq("Successfully reprocessed 1 submission(s) with CANCEL-ME-123 error!")
          end
        end
      end

      context "in failed states" do
        let!(:transition_error) {
          create :efile_submission_transition_error,
                 efile_error: wait_efile_error,
                 efile_submission_transition: failed_submission.last_transition,
                 efile_submission_id: failed_submission.id
        }

        context "with auto_cancel error" do
          let!(:transition_error) { create :efile_submission_transition_error, efile_error: cancel_efile_error, efile_submission_transition: failed_submission.last_transition, efile_submission_id: failed_submission.id }
          let(:params) do
            {
              id: cancel_efile_error.id,
            }
          end
          it "successfully transitions submissions in a rejected state to the auto-transition cancelled state on the error" do
            expect(failed_submission.current_state).to eq "failed"
            patch :reprocess, params: params
            expect(failed_submission.current_state(force_reload: true)).to eq "cancelled"
            expect(flash[:notice]).to eq("Successfully reprocessed 1 submission(s) with CANCEL-ME-123 error!")
          end
        end

        context "with only auto_wait errors" do
          it "does not transition submissions those with a different error" do
            expect(failed_submission.current_state).to eq "failed"
            patch :reprocess, params: params
            expect(failed_submission.current_state(force_reload: true)).to eq "waiting"
          end
        end

        context "with non-auto_wait errors" do
          let!(:not_waiting_transition_error) {
            create :efile_submission_transition_error,
                   efile_error: not_handled_error,
                   efile_submission_transition: failed_submission.last_transition,
                   efile_submission_id: failed_submission.id
          }
          it "does not transition submissions those with a different error" do
            expect(failed_submission.current_state).to eq "failed"
            patch :reprocess, params: params
            expect(failed_submission.current_state(force_reload: true)).to eq "failed"
          end
        end
      end

      context "in cancelled states" do
        it "does not transition submissions in a non-failed/rejected state or those with a different error" do
          expect(cancelled_submission.current_state).to eq "cancelled"
          patch :reprocess, params: params
          expect(cancelled_submission.current_state(force_reload: true)).to eq "cancelled"
        end
      end

      context "with no auto-transition on the error" do
        let(:params) do
          {
            id: not_handled_error.id,
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