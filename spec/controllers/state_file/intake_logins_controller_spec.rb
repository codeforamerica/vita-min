require "rails_helper"

RSpec.describe StateFile::IntakeLoginsController, type: :controller do
  let(:intake) do
    create(
      :state_file_az_intake,
      email_address: "client@example.com",
      sms_phone_number: "+15105551234",
      hashed_ssn: "hashed_ssn"
    )
  end
  let(:intake_query) { StateFileAzIntake.where(id: intake) }

  before do
    allow(DatadogApi).to receive(:increment)
  end

  describe "#new" do
    context "with required params" do
      it "returns 200 OK for phone number" do
        get :new, params: { contact_method: :sms_phone_number, us_state: "az" }

        expect(response).to be_ok
      end

      it "returns 200 OK for email" do
        get :new, params: { contact_method: :email_address, us_state: "az" }

        expect(response).to be_ok
      end
    end

    context "without required params" do
      it "returns 404" do
        get :new, params: { us_state: "az" }

        expect(response).to be_not_found
      end
    end

    context "as an authenticated intake" do
      before { sign_in intake }

      it "redirects to data review page" do
        get :new, params: { us_state: "az" }

        expect(response).to redirect_to az_questions_data_review_path(us_state: "az")
      end
    end
  end

  describe "#create", active_job: true do
    before { allow(subject).to receive(:visitor_id).and_return "visitor id" }
    let(:params) do
      {
        locale: "es",
        us_state: "az",
        contact_method: contact_method,
        state_file_request_intake_login_form: contact_info_params
      }
    end

    context "with valid params" do
      context "with an email address" do
        let(:contact_method) { :email_address }
        let(:contact_info_params) do
          {
            email_address: "client@example.com",
            sms_phone_number: nil
          }
        end

        it "enqueues a RequestVerificationCodeEmailJob and renders a form for the code" do
          expect {
            post :create, params: params
          }.to have_enqueued_job(RequestVerificationCodeForLoginJob).with(
            email_address: "client@example.com",
            phone_number: "",
            locale: :es,
            visitor_id: "visitor id",
            service_type: :statefile_az
          )

          expect(response).to be_ok
          expect(response).to render_template(:enter_verification_code)
        end
      end

      context "with an SMS phone number" do
        let(:contact_method) { :sms_phone_number }
        let(:contact_info_params) do
          {
            email_address: nil,
            sms_phone_number: " (510) 555 1234"
          }
        end

        it "enqueues a text message login request job with the right data and renders the 'enter verification code' page" do
          expect {
            post :create, params: params
          }.to have_enqueued_job(RequestVerificationCodeForLoginJob).with(
            phone_number: "+15105551234",
            email_address: "",
            locale: :es,
            visitor_id: "visitor id",
            service_type: :statefile_az
          )
          expect(response).to be_ok
          expect(response).to render_template(:enter_verification_code)
        end
      end
    end

    context "with invalid params" do
      context "bad email" do
        let(:contact_method) { :email_address }
        let(:contact_info_params) do
          {
            email_address: "client@example",
            sms_phone_number: ""
          }
        end

        it "does not enqueue a client login request and renders new" do
          post :create, params: params

          expect(response).to render_template :new
          expect(RequestVerificationCodeForLoginJob).not_to have_been_enqueued
        end
      end

      context "blank email" do
        let(:contact_method) { :email_address }
        let(:contact_info_params) do
          {
            email_address: nil,
            sms_phone_number: ""
          }
        end

        it "does not enqueue a client login request and renders new" do
          post :create, params: params

          expect(response).to render_template :new
          expect(assigns(:form).errors[:email_address]).to include "No puede estar en blanco."
          expect(RequestVerificationCodeForLoginJob).not_to have_been_enqueued
        end
      end

      context "blank phone" do
        let(:contact_method) { :sms_phone_number }
        let(:contact_info_params) do
          {
            email_address: "",
            sms_phone_number: nil
          }
        end

        it "does not enqueue a client login request and renders new" do
          post :create, params: params

          expect(response).to render_template :new
          expect(assigns(:form).errors[:sms_phone_number]).to include "No puede estar en blanco."
          expect(RequestVerificationCodeForLoginJob).not_to have_been_enqueued
        end
      end
    end

    context "as an authenticated intake" do
      before { sign_in intake }

      it "redirects to data review page" do
        post :create, params: { us_state: "az" }

        expect(response).to redirect_to az_questions_data_review_path(us_state: "az")
      end
    end
  end

  describe "#check_verification_code" do
    context "with valid params" do
      let(:intake) { create :state_file_az_intake }
      let(:email_address) { "example@example.com" }
      let(:verification_code) { "000004" }
      let(:hashed_verification_code) { "hashed_verification_code" }
      let(:params) do
        {
          us_state: "az",
          portal_verification_code_form: {
            contact_info: email_address,
            verification_code: verification_code
          }
        }
      end

      before do
        allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(email_address, verification_code).and_return(hashed_verification_code)
        allow_any_instance_of(ClientLoginService).to receive(:login_records_for_token).with(hashed_verification_code).and_return(intake_query)
      end

      it "redirects to the next page for login" do
        post :check_verification_code, params: params

        expect(response).to redirect_to(edit_intake_login_path(id: hashed_verification_code, us_state: "az"))
      end

      context "Datadog" do
        it "increments a counter" do
          post :check_verification_code, params: params

          expect(DatadogApi).to have_received(:increment).with("intake_logins.verification_codes.right_code")
        end
      end
    end

    context "with invalid params" do
      let(:email_address) { "example@example.com" }
      let(:params) {
        {
          us_state: "ny",
          portal_verification_code_form: {
            contact_info: email_address,
            verification_code: verification_code,
          }
        }
      }
      let!(:intake) { create :state_file_ny_intake, email_address: email_address }

      context "with clients matching the contact info but invalid verification code" do
        let(:verification_code) { "000005" }
        let(:hashed_wrong_verification_code) { "hashed_wrong_verification_code" }

        before do
          allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(email_address, verification_code).and_return(hashed_wrong_verification_code)
          allow_any_instance_of(ClientLoginService).to receive(:login_records_for_token).with(hashed_wrong_verification_code).and_return(StateFileNyIntake.none)
        end

        it "increments their lockout counter & shows an error in the form" do
          expect {
            post :check_verification_code, params: params
          }.to change { intake.reload.failed_attempts }

          expect(response).to be_ok
          expect(assigns[:verification_code_form]).to be_present
          expect(assigns[:verification_code_form].errors).to include(:verification_code)
        end

        context "Datadog" do
          it "increments a counter" do
            post :check_verification_code, params: params

            expect(DatadogApi).to have_received(:increment).with("intake_logins.verification_codes.wrong_code")
          end
        end
      end

      context "with clients matching the contact info & token but locked out" do
        let(:verification_code) { "000005" }
        let(:hashed_verification_code) { "hashed_verification_code" }

        before do
          intake.update(locked_at: DateTime.now)
          allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(email_address, verification_code).and_return(hashed_verification_code)
          allow_any_instance_of(ClientLoginService).to receive(:login_records_for_token).with(hashed_verification_code).and_return(intake_query)
        end

        it "redirects to the account locked page" do
          post :check_verification_code, params: params

          expect(response).to redirect_to(account_locked_portal_client_logins_path)
        end
      end

      context "with blank contact info" do
        let(:params) {
          {
            us_state: "ny",
            portal_verification_code_form: {
              contact_info: "",
              verification_code: "999999",
            }
          }
        }

        it "shows a Bad Request error" do
          post :check_verification_code, params: params
          expect(response.status).to eq(400)
        end
      end

      context "with invalid data in the verification code" do
        let(:params) {
          {
            us_state: "ny",
            portal_verification_code_form: {
              contact_info: email_address,
              verification_code: "invalid",
            }
          }
        }

        it "re-renders the form with errors and does not increment lockout counter" do
          expect {
            post :check_verification_code, params: params
          }.not_to change { intake.reload.failed_attempts }

          expect(response).to be_ok
          expect(assigns[:verification_code_form].errors).to include(:verification_code)
        end
      end
    end
  end

  describe "#edit" do
    let(:params) { { us_state: "az", id: "raw_token" } }

    context "as an unauthenticated client" do
      context "with valid token" do
        before { allow_any_instance_of(ClientLoginService).to receive(:login_records_for_token).and_return(intake_query) }

        it "it is ok" do
          get :edit, params: params

          expect(response).to be_ok
        end

        context "when the intake is locked" do
          before do
            intake.lock_access!
          end

          it "redirects to the lockout page" do
            get :edit, params: params

            expect(response).to redirect_to account_locked_portal_client_logins_path
          end
        end

        context "when the intake does not have an ssn" do
          before { intake.update(hashed_ssn: nil) }

          it "redirects to terms and conditions page" do
            get :edit, params: params

            expect(response).to redirect_to az_questions_terms_and_conditions_path(us_state: "az")
          end
        end
      end

      context "with invalid token" do
        before { allow_any_instance_of(ClientLoginService).to receive(:login_records_for_token).and_return(StateFileAzIntake.none) }

        it "redirects to the portal login page" do
          get :edit, params: params

          expect(response).to redirect_to(intake_logins_path(us_state: "az"))
        end
      end
    end

    context "as an authenticated intake" do
      before do
        allow_any_instance_of(ClientLoginService).to receive(:login_records_for_token).and_return(intake_query)
        sign_in intake
      end

      it "redirects to data review page" do
        get :edit, params: params

        expect(response).to redirect_to az_questions_data_review_path(us_state: "az")
      end

      context "when the intake does not have an ssn" do
        before { intake.update(hashed_ssn: nil) }

        it "redirects to terms and conditions page" do
          get :edit, params: params
          expect(response).to redirect_to az_questions_terms_and_conditions_path(us_state: "az")
        end
      end
    end
  end

  describe "#update" do
    let(:ssn) { "111223333" }
    let(:params) { { us_state: "az", id: "raw_token", ssn: ssn } }

    context "as an unauthenticated intake" do
      context "with a valid token" do
        let(:params) do
          {
            us_state: "az",
            id: "raw_token",
            state_file_intake_login_form: {
              ssn: ssn
            }
          }
        end
        before { allow_any_instance_of(ClientLoginService).to receive(:login_records_for_token).and_return(intake_query) }

        context "with a matching ssn" do
          before do
            allow(SsnHashingService).to receive(:hash).with(ssn).and_return intake.hashed_ssn
          end

          it "signs in the intake, updates the session, and redirects to data review page" do
            post :update, params: params

            expect(subject.current_state_file_az_intake).to eq(intake)
            expect(response).to redirect_to az_questions_data_review_path(us_state: "az")
            expect(GlobalID.find(session[:state_file_intake])).to eq intake
          end

          context "when they were trying to access a protected page" do
            let(:original_path) { "/questions/fake-page?test=1234" }

            before do
              session[:after_state_file_intake_login_path] = original_path
            end

            it "redirects to that page and removes the path from the session" do
              post :update, params: params

              expect(response).to redirect_to original_path
              expect(session).not_to include :after_state_file_intake_login_path
            end
          end

          context "when they are locked out" do
            before do
              intake.lock_access!
            end

            it "redirects to an account-locked page" do
              post :update, params: params

              expect(response).to redirect_to account_locked_portal_client_logins_path
            end
          end
        end

        context "without a matching ssn" do
          before do
            allow(SsnHashingService).to receive(:hash).with(ssn).and_return "something_else"
          end

          it "renders the :edit template and increments a lockout number" do
            expect do
              post :update, params: params
            end.to change { intake.reload.failed_attempts }.by 1

            expect(subject.current_state_file_az_intake).to eq(nil)
            expect(response).to render_template(:edit)
          end

          context "with 4 previous failed attempts" do
            before do
              intake.update(failed_attempts: 4)
            end

            it "locks the intake and redirects to a lockout page" do
              expect do
                post :update, params: params
              end.to change { intake.reload.failed_attempts }.by 1
              expect(intake.reload.access_locked?).to be_truthy

              expect(response).to redirect_to(account_locked_portal_client_logins_path)
            end
          end
        end
      end

      context "with an invalid token" do
        before { allow_any_instance_of(ClientLoginService).to receive(:login_records_for_token).and_return(StateFileAzIntake.none) }

        it "redirects to the login page" do
          post :update, params: params

          expect(response).to redirect_to(intake_logins_path(us_state: "az"))
        end
      end
    end

    context "as an authenticated intake" do
      before do
        allow_any_instance_of(ClientLoginService).to receive(:login_records_for_token).and_return(intake_query)
        sign_in intake
      end

      it "redirects to data review page" do
        post :update, params: params

        expect(response).to redirect_to az_questions_data_review_path(us_state: "az")
      end
    end
  end
end