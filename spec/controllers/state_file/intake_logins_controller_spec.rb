require "rails_helper"

RSpec.describe StateFile::IntakeLoginsController, type: :controller do
  let(:intake) do
    create(
      :state_file_az_intake,
      email_address: "client@example.com",
      sms_phone_number: "+15105551234"
    )
  end

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
        portal_request_client_login_form: contact_info_params
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

    context "as an authenticated client" do
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
        allow_any_instance_of(ClientLoginService).to receive(:login_records_for_token).with(hashed_verification_code).and_return(intake)
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

      # TODO: match this behavior
      xcontext "with clients matching the contact info & token but locked out" do
        let(:verification_code) { "000005" }
        let(:hashed_verification_code) { "hashed_verification_code" }

        before do
          intake.update(locked_at: DateTime.now)
          allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(email_address, verification_code).and_return(hashed_verification_code)
          allow_any_instance_of(ClientLoginService).to receive(:login_records_for_token).with(hashed_verification_code).and_return([intake])
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
end