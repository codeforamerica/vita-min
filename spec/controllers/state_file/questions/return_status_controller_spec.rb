require "rails_helper"

RSpec.describe StateFile::Questions::ReturnStatusController do
  StateFile::StateInformationService.active_state_codes.each do |state_code|
    context "#{state_code}" do
      describe "#edit" do
        render_views
        let(:intake) { create(StateFile::StateInformationService.intake_class(state_code).name.underscore.to_sym) }

        before do
          sign_in intake
        end

        context "assignment of various instance variables" do
          it "assigns the ones from the config service correctly" do
            create(:efile_submission, :notified_of_rejection, :for_state, data_source: intake)
            get :edit

            expect(assigns(:tax_refund_url)).to eq StateFile::StateInformationService.tax_refund_url(state_code)
            expect(assigns(:tax_payment_url)).to eq StateFile::StateInformationService.tax_payment_url(state_code)
            expect(assigns(:voucher_form_name)).to eq StateFile::StateInformationService.voucher_form_name(state_code)
            expect(assigns(:mail_voucher_address)).to eq StateFile::StateInformationService.mail_voucher_address(state_code)
            expect(assigns(:voucher_path)).to eq StateFile::StateInformationService.voucher_path(state_code)
            expect(assigns(:survey_link)).to eq StateFile::StateInformationService.survey_link(state_code)
          end

          context "submission" do
            let!(:efile_submission_first) { create(:efile_submission, :notified_of_rejection, :for_state, data_source: intake) }
            let!(:efile_submission_last) { create(:efile_submission, :notified_of_rejection, :for_state, data_source: intake) }

            it "assigns the most recent submission to submission_to_show" do
              get :edit

              expect(assigns(:submission_to_show)).to eq efile_submission_last
            end
          end

          context "return status" do
            it "maps to accepted, rejected, or pending" do
              create(:efile_submission, :accepted, :for_state, data_source: intake)
              get :edit
              expect(assigns(:return_status)).to eq 'accepted'

              create(:efile_submission, :notified_of_rejection, :for_state, data_source: intake)
              get :edit
              expect(assigns(:return_status)).to eq 'rejected'

              create(:efile_submission, :waiting, :for_state, data_source: intake)
              get :edit
              expect(assigns(:return_status)).to eq 'rejected'

              EfileSubmissionStateMachine.states.excluding("accepted", "notified_of_rejection", "waiting").each do |status|
                create(:efile_submission, status, :for_state, data_source: intake)
                get :edit
                expect(assigns(:return_status)).to eq 'pending'
              end
            end
          end

          context "efile error" do
            context "should expose error" do
              [:notified_of_rejection, :waiting].each do |status|
                let!(:efile_submission) { create(:efile_submission, :rejected, :with_errors, :for_state, data_source: intake) }
                let(:error) { efile_submission.efile_submission_transitions.where(to_state: 'rejected').last.efile_errors.last }
                before do
                  efile_submission.transition_to!(status)
                end

                it "assigns the last efile error attached to the last transition when #{status}" do
                  get :edit

                  expect(error).to be_a(EfileError)
                  expect(assigns(:error)).to eq error
                end
              end
            end

            context "other status" do
              EfileSubmissionStateMachine.states.excluding("notified_of_rejection", "waiting").each do |status|
                it "assigns nil when #{status}" do
                  efile_submission = create(:efile_submission, :rejected, :with_errors, :for_state, data_source: intake)
                  if efile_submission.can_transition_to?(status) # when status is after rejected, transition and make sure there is an error available
                    efile_submission.transition_to!(status)
                    error = efile_submission.efile_submission_transitions.where(to_state: 'rejected').last.efile_errors.last
                    expect(error).to be_a(EfileError)
                  else # when status is before rejected, delete the submission and start over
                    efile_submission.destroy!
                    create(:efile_submission, status, :for_state, data_source: intake)
                  end

                  get :edit

                  expect(assigns(:error)).to be_nil
                end
              end
            end
          end
        end
      end
    end
  end
end