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
        us_state: "az" ,
        portal_request_client_login_form: contact_info_params
      }
    end

    context "with valid params" do
      before do
        allow(subject).to receive(:visitor_id).and_return "visitor id"
      end

      context "with an email address" do
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

  xdescribe "#check_verification_code" do
    #  TODO: see client_logins_controller_spec
  end
end
