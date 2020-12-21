require 'rails_helper'

describe Hub::OutboundCallsController, type: :controller do
  describe '#create' do
    let(:client) { create :client, intake: (create :intake, phone_number: "+18324658890") }
    let(:user) { create :admin_user }
    let(:user_phone_number) { "+18324658840" }
    let(:client_phone_number) { "+18324651680" }

    let(:params) { { client_id: client.id, hub_outbound_call_form: { user_phone_number: user_phone_number, client_phone_number: client_phone_number} }}
    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create
    context "with an authenticated user" do
      before { sign_in user }
      it "instantiates the form object" do
        post :create, params: params
        expect(assigns(:form)).to be_an_instance_of(Hub::OutboundCallForm)
      end

      context "when @form.call! fails" do
        before do
          allow_any_instance_of(Hub::OutboundCallForm).to receive(:call!).and_return false
        end

        it "renders the new template" do
          post :create, params: params
          expect(response).to render_template :new
        end
      end

      context "when @form.call! is successful" do
        let!(:outbound_call) { create :outbound_call, client: client, user: user }
        before do
          allow_any_instance_of(Hub::OutboundCallForm).to receive(:call!).and_return outbound_call
        end

        it "redirects to show" do
          post :create, params: params
          expect(response).to redirect_to (hub_client_outbound_call_path(client_id: client.id, id: outbound_call.id))
        end
      end
    end
  end

  describe "#show" do
    let(:client) { create :client }
    let(:params) { { client_id: client.id, id: "123" } }
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show
  end

  describe "#new" do
    let(:client) { create :client, intake: (create :intake, phone_number: "+18324658840") }
    let(:user) { create :admin_user }
    let(:params) { { client_id: client.id }}
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :new

    context "with an authenticated user" do
      before { sign_in user }

      it "instantiates an outbound call form" do
        get :new, params: params
        expect(assigns(:form)).to be_an_instance_of(Hub::OutboundCallForm)
      end
    end
  end

  describe "#call" do
    render_views
    let(:client) { create :client }
    let(:params) { { id: client.id, phone_number: "+18324658840" } }

    context "with an authenticated user" do
      it "responds with xml" do
        post :call, params: params, format: :xml
        expect(response.body).to include "<Say>Please wait while we connect your call.</Say>"
        expect(response.body).to include "<Dial>+18324658840</Dial>"
      end
    end
  end
end