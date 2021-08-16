require "rails_helper"

describe Ctc::Questions::IncomeController do
  context '#update' do
    let(:ip_address) { "127.0.0.1" }
    let(:had_reportable_income) { "no" }
    let(:params) do
      {
        ctc_income_form: {
          timezone: "America/Chicago",
          had_reportable_income: had_reportable_income,
          device_id: "7BA1E530D6503F380F1496A47BEB6F33E40403D1",
          user_agent: "GeckoFox",
          browser_language: "en-US",
          platform: "iPad",
          timezone_offset: "+240",
          client_system_time: "2021-07-28T21:21:32.306Z",
        }
      }
    end

    before do
      request.remote_ip = ip_address
      cookies[:visitor_id] = "visitor-id"
      session[:source] = "some-source"

      allow(MixpanelService).to receive(:send_event)
    end

    it "sends an event to mixpanel" do
      post :update, params: params

      expect(MixpanelService).to have_received(:send_event).with(hash_including(
        event_name: "question_answered",
        data: { had_reportable_income: "no" }
      ))
    end

    it "updates client with intake security information" do
      post :update, params: params

      client = Client.last
      expect(client.efile_security_information.user_agent).to eq "GeckoFox"
      expect(client.efile_security_information.ip_address).to eq ip_address
    end

    context "when answer is yes" do
      let(:had_reportable_income) { "yes" }
      it "redirects out of the flow" do
        post :update, params: params
        expect(response).to redirect_to questions_use_gyr_path
      end
    end

    context "when the answer is no" do
      let(:had_reportable_income) { "no" }

      it "redirects to the next page in the flow" do
        post :update, params: params
        expect(response).to redirect_to questions_file_full_return_path
      end
    end

    context "efile security information fields are missing" do
      let(:params) do
        {
          ctc_income_form: {
          }
        }
      end

      it "does not create the client, shows a flash message" do
        expect {
          post :update, params: params
        }.not_to change(Client, :count)

        expect(flash[:alert]).to eq I18n.t("general.enable_javascript")
      end
    end
  end
end
