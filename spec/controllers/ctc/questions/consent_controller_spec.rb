require "rails_helper"

describe Ctc::Questions::ConsentController do
  let(:intake) { Intake::CtcIntake.new(visitor_id: "visitor-id", source: "some-source") }

  before do
    cookies[:visitor_id] = "visitor-id"
    session[:source] = "some-source"
    allow(MixpanelService).to receive(:send_event)
  end

  describe "#edit" do
    it "renders edit template and initializes form" do
      get :edit, params: {}
      expect(response).to render_template :edit
      expect(assigns(:form)).to be_an_instance_of Ctc::ConsentForm
      expect(assigns(:form).intake).to be_an_instance_of Intake::CtcIntake
    end

    it "initializes the current intake with a visitor id and source" do
      expect {
        get :edit, params: {}
      }.to change(Intake, :count).by(1)
      intake = Intake.last
      expect(intake.visitor_id).to eq("visitor-id")
      expect(intake.source).to eq("some-source")
    end
  end

  describe "#update" do
    let(:ip_address) { "127.0.0.1" }

    before do
      request.remote_ip = ip_address
    end

    context "with valid params" do
      let(:params) do
        {
          ctc_consent_form: {
            primary_first_name: "Marty",
            primary_middle_initial: "J",
            primary_last_name: "Mango",
            primary_birth_date_year: "1963",
            primary_birth_date_month: "9",
            primary_birth_date_day: "10",
            primary_ssn: "111-22-8888",
            primary_ssn_confirmation: "111-22-8888",
            primary_active_armed_forces: "no",
            phone_number: "831-234-5678",
            timezone: "America/Chicago",
            primary_tin_type: "ssn",
            device_id: "7BA1E530D6503F380F1496A47BEB6F33E40403D1",
            user_agent: "GeckoFox",
            browser_language: "en-US",
            platform: "iPad",
            timezone_offset: "+240",
            client_system_time: "2021-07-28T21:21:32.306Z",
          }
        }
      end

      it "updates client with intake personal info and efile security information" do
        post :update, params: params

        client = Client.last
        expect(client.intake.primary_first_name).to eq "Marty"
        expect(client.efile_security_information.user_agent).to eq "GeckoFox"
        expect(client.efile_security_information.ip_address).to eq ip_address
      end
    end
  end
end
