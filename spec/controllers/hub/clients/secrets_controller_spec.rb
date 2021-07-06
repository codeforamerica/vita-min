require 'rails_helper'

describe Hub::Clients::SecretsController, type: :controller do
  describe "#show" do
    let(:client) { create :client }

    let(:params) { { id: client.id, secret_name: secret_name } }
    let(:secret_name) { "primary_ssn" }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show

    context "with a logged in user" do
      let(:back_to_the_future_day) { DateTime.new(2015, 10, 21, 0, 0, 0) }
      let(:user) { create(:admin_user) }
      let(:user_agent_header) { "CERN-NextStep-WorldWideWeb.app/1.1 libwww/2.07" }

      before do
        allow(DateTime).to receive(:now).and_return(back_to_the_future_day)
        request.remote_ip = "1.1.1.1"
        request.headers["HTTP_USER_AGENT"] = user_agent_header
        sign_in user
      end

      it "loads the appropriate client" do
        get :show, params: params, format: :js, xhr: true
        expect(assigns(:client)).to eq client
      end

      it "responds with js" do
        get :show, params: params, format: :js, xhr: true
        expect(response.media_type).to eq "text/javascript"
      end

      it "does not respond with html" do
        expect { get :show, params: params }.to raise_error ActionController::UnknownFormat
      end

      context "AccessLogs" do
        context "when the secret type is an ssn" do
          let(:secret_name) { "primary_ssn" }

          it "creates an AccessLog for ssns" do
            expect { get :show, params: params, format: :js, xhr: true }.to change(AccessLog, :count).by(1)
            access_log = AccessLog.last
            expect(access_log.user).to eq(user)
            expect(access_log.record).to eq(client)
            expect(access_log.event_type).to eq("read_ssn_itin")
            expect(access_log.created_at).to eq(back_to_the_future_day)
            expect(access_log.ip_address).to eq("1.1.1.1")
            expect(access_log.user_agent).to eq(user_agent_header)
          end
        end

        context "when the secret type is IP PIN" do
          let(:secret_name) { "spouse_ip_pin" }

          it "creates an AccessLog for ip_pins" do
            expect { get :show, params: params, format: :js, xhr: true }.to change(AccessLog, :count).by(1)
            access_log = AccessLog.last
            expect(access_log.user).to eq(user)
            expect(access_log.record).to eq(client)
            expect(access_log.event_type).to eq("read_ip_pin")
            expect(access_log.created_at).to eq(back_to_the_future_day)
            expect(access_log.ip_address).to eq("1.1.1.1")
            expect(access_log.user_agent).to eq(user_agent_header)
          end
        end
      end
    end
  end

  describe "#hide" do
    let(:client) { create :client }

    let(:params) { { id: client.id } }
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show

    context "with a logged in user" do
      before { sign_in (create :admin_user) }

      it "loads the appropriate client" do
        get :hide, params: params, format: :js, xhr: true
        expect(assigns(:client)).to eq client
      end

      it "responds with js" do
        get :hide, params: params, format: :js, xhr: true
        expect(response.media_type).to eq "text/javascript"
      end

      it "does not respond with html" do
        expect { get :hide, params: params }.to raise_error ActionController::UnknownFormat
      end
    end
  end
end
