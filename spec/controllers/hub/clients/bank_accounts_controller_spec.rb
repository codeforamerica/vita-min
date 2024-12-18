require 'rails_helper'

describe Hub::Clients::BankAccountsController, type: :controller do
  describe "#show" do
    let(:client) { create :client, intake: (build :intake) }

    let(:params) { { id: client.id } }
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show

    context "with a logged in user" do
      let(:back_to_the_future_day) { DateTime.new(2015, 10, 21, 0, 0, 0)}
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
        get :show, params: params
        expect(response).to be_not_found
      end

      it "creates an AccessLog" do
        expect { get :show, params: params, format: :js, xhr: true }.to change(AccessLog, :count).by(1)
        access_log = AccessLog.last
        expect(access_log.user).to eq(user)
        expect(access_log.record).to eq(client)
        expect(access_log.event_type).to eq("read_bank_account_info")
        expect(access_log.created_at).to eq(back_to_the_future_day)
        expect(access_log.ip_address).to eq("1.1.1.1")
        expect(access_log.user_agent).to eq(user_agent_header)
      end

      context "for an archived intake" do
        render_views

        let(:intake) { nil }
        let(:client) { build(:client) }

        let!(:archived_intake) { create :archived_2021_ctc_intake, client: client, primary_ssn: '555-11-2222', preferred_name: "Andy Archive" }
        let!(:archived_bank_account) {  create(:archived_2021_bank_account, intake: archived_intake) }

        it "shows the secret from the archived intake" do
          get :show, params: params, format: :js, xhr: true
          expect(response.body).to include(archived_bank_account.routing_number)
        end
      end

      context "for a greeter" do
        let(:user) { create(:greeter_user) }

        it "prevents access" do
          get :show, params: params, format: :js, xhr: true
          expect(response).to be_forbidden
        end
      end
    end
  end

  describe "#hide" do
    let(:client) { create :client, intake: build(:intake) }

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
        get :show, params: params
        expect(response).to be_not_found
      end
    end
  end
end
