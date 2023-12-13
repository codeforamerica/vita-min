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
      it "returns 200 OK" do
        get :new, params: { contact_method: :sms_phone_number, us_state: "az" }

        expect(response).to be_ok
      end

      it "returns 200 OK" do
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
    let(:params) do
      {
        locale: "es",
        us_state: "az",
        contact_method: contact_method,
        portal_request_client_login_form: contact_info_params
      }
    end

    context "with valid params" do
      before do
        allow(subject).to receive(:visitor_id).and_return "visitor id"
      end

      context "with an email address" do
        let(:contact_method) { :email_address }
        let(:contact_info_params) do
          {
            email_address: "client@example.com",
            sms_phone_number: nil
          }
        end

        it "enqueues a RequestVerificationCodeEmailJob" do
          expect {
            post :create, params: params
          }.to have_enqueued_job(RequestVerificationCodeForLoginJob).with(
            email_address: "client@example.com",
            phone_number: "",
            locale: :es,
            visitor_id: "visitor id",
            service_type: :statefile
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
            service_type: :statefile
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

  describe "#edit" do
    let(:params) do
      {
        id: "raw_token",
        us_state: "ny"
      }
    end

    context "as an unauthenticated client" do
    #  TODO: see client_logins_controller_spec
    end

    context "as an authenticated client" do
      before do
        sign_in intake
      end

      it "redirects to data review page" do
        get :edit, params: params

        expect(response).to redirect_to ny_questions_data_review_path(us_state: "ny")
      end
    end
  end

  xdescribe "#update" do
    #  TODO: see client_logins_controller_spec
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
        # TODO: decide whether to use same service, same method, etc.
        allow_any_instance_of(ClientLoginService).to receive(:intakes_for_token).with(hashed_verification_code).and_return(intake)
      end

      it "redirects to the next page for login" do
        post :check_verification_code, params: params

        expect(response).to redirect_to(edit_state_file_az_intake_login_path(id: hashed_verification_code, us_state: "az"))
      end

      context "Datadog" do
        it "increments a counter" do
          post :check_verification_code, params: params

          expect(DatadogApi).to have_received(:increment).with("intake_logins.verification_codes.right_code")
        end
      end
    end

    xcontext "with invalid params" do
    #  TODO: see client logins controller spec
    end
  end
end
