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

                it "when #{status}, assigns the last efile error attached to the last rejected transition" do
                  get :edit

                  expect(error).to be_a(EfileError)
                  expect(assigns(:error)).to eq error
                end
              end
            end

            context "other status" do
              [:new, :preparing, :bundling, :queued, :transmitted, :ready_for_ack, :failed, :rejected, :accepted].each do |status|
                it "when #{status}, assigns nil" do
                  create(:efile_submission, status, :for_state, data_source: intake)

                  get :edit

                  expect(assigns(:error)).to be_nil
                end
              end

              [:investigating, :fraud_hold, :resubmitted, :cancelled].each do |status|
                it "when #{status}, assigns nil even if errors exist" do
                  efile_submission = create(:efile_submission, :rejected, :with_errors, :for_state, data_source: intake)
                  efile_submission.transition_to!(status)
                  error = efile_submission.efile_submission_transitions.where(to_state: 'rejected').last.efile_errors.last
                  expect(error).to be_a(EfileError)

                  get :edit

                  expect(assigns(:error)).to be_nil
                end
              end
            end
          end
        end

        context "pending" do
          before do
            create(:efile_submission, :transmitted, :for_state, data_source: intake)
          end

          it "shows the pending view" do
            get :edit

            expect(response.body).to include I18n.t("state_file.questions.return_status.pending.title",
                                                    state_name: StateFile::StateInformationService.state_name(state_code),
                                                    filing_year: MultiTenantService.statefile.current_tax_year)
          end

          it "shows email and text content when opted into both" do
            intake.update(sms_notification_opt_in: "yes", email_notification_opt_in: "yes")
            get :edit
            expect(response.body.html_safe).to include CGI.escapeHTML(I18n.t("state_file.questions.submission_confirmation.edit.email_text_update"))
          end

          it "shows language associated with text when only opted in to text" do
            intake.update(sms_notification_opt_in: "yes", email_notification_opt_in: "no")
            get :edit
            expect(response.body).to include CGI.escapeHTML(I18n.t("state_file.questions.submission_confirmation.edit.text_update"))
            expect(response.body).not_to include CGI.escapeHTML(I18n.t("state_file.questions.return_status.pending.check_spam"))
          end

          it "shows language associated with email when only opted in to email" do
            intake.update(sms_notification_opt_in: "no", email_notification_opt_in: "yes")
            get :edit
            expect(response.body).to include CGI.escapeHTML(I18n.t("state_file.questions.submission_confirmation.edit.email_update"))
            expect(response.body).to include CGI.escapeHTML(I18n.t("state_file.questions.return_status.pending.check_spam"))
          end
        end

        context "accepted" do
          before do
            create(:efile_submission, :accepted, :for_state, data_source: intake)
          end

          it "shows the accepted view" do
            get :edit

            expect(response.body).to include I18n.t("state_file.questions.return_status.accepted.title",
                                                    state_name: StateFile::StateInformationService.state_name(state_code),
                                                    filing_year: MultiTenantService.statefile.current_tax_year)
          end
        end

        context "rejected" do
          before do
            efile_submission = create(:efile_submission, :rejected, :with_errors, :for_state, data_source: intake)
            efile_submission.transition_to(:notified_of_rejection)
          end

          it "shows the rejected view" do
            get :edit

            expect(response.body).to include I18n.t("state_file.questions.return_status.rejected.title",
                                                    state_name: StateFile::StateInformationService.state_name(state_code),
                                                    filing_year: MultiTenantService.statefile.current_tax_year)
          end

          context "showing the error" do
            context "expose error" do
              it "shows the reject code, the description, and the resolution" do
                get :edit
                error = assigns(:error)
                expect(response.body).to include error.code
                expect(response.body).to include CGI.escapeHTML(error.message)
              end
            end

            context "do not expose error" do
              it "does not show info about the error" do
                get :edit
                error = assigns(:error)
                error.update(expose: false)

                get :edit
                expect(response.body).not_to include error.code
                expect(response.body).not_to include CGI.escapeHTML(error.message)
              end
            end
          end
        end
      end
    end
  end
end