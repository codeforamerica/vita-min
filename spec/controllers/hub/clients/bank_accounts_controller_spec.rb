require 'rails_helper'

describe Hub::Clients::BankAccountsController, type: :controller do
  describe "#show" do
    let(:client) { create :client }

    let(:params) { { id: client.id } }
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show

    context "with a logged in user" do
      before { sign_in (create :admin_user) }

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
        expect { get :show, params: params }.to raise_error ActionController::UnknownFormat
      end
    end
  end
end