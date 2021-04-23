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

      context "when @form.dial fails" do
        before do
          allow_any_instance_of(Hub::OutboundCallForm).to receive(:dial).and_return false
        end

        it "renders the new template" do
          post :create, params: params
          expect(response).to render_template :new
        end
      end

      context "when @form.dial is successful" do
        let!(:outbound_call) { create :outbound_call, client: client, user: user }
        before do
          allow_any_instance_of(Hub::OutboundCallForm).to receive(:dial)
          allow_any_instance_of(Hub::OutboundCallForm).to receive(:outbound_call).and_return outbound_call
        end

        it "redirects to show" do
          post :create, params: params
          expect(response).to redirect_to hub_client_outbound_call_path(client_id: client.id, id: outbound_call.id)
        end
      end
    end
  end

  describe "#show" do
    let(:filing_jointly) { "no" }
    let(:client) { create :client, intake: build(:intake, primary_last_four_ssn: "2222", filing_joint: filing_jointly, spouse_last_four_ssn: "1111") }
    let(:outbound_call) { create :outbound_call, client: client }
    let(:params) { { client_id: client.id, id: outbound_call.id } }
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show

    context "with a logged in user" do
      let(:user) { create :admin_user }
      before { sign_in user }
      render_views

      it "shows the ssn last four" do
        get :show, params: params

        expect(response.body).to have_text "2222"
        expect(response.body).not_to have_text "Spouse's last 4 of SSN/ITIN:"
      end

      context "with a client filing jointly" do
        let(:filing_jointly) { "yes" }

        it "shows the ssn last four" do
          get :show, params: params

          expect(response.body).to have_text "Spouse's last 4 of SSN/ITIN:"
          expect(response.body).to have_text "1111"
        end
      end
    end
  end

  describe "#update" do
    let(:client) { create :client }
    let(:user) { create :admin_user }
    let(:outbound_call) { create :outbound_call, client: client }
    let(:params) { { client_id: client.id, id: outbound_call.id, outbound_call: { note: "I talked to them!"} } }
    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "with a logged in user" do
      before { sign_in user }

      it "updates the outbound call with the note body and redirects back to messages" do
        put :update, params: params

        expect(outbound_call.reload.note).to eq "I talked to them!"
        expect(response).to redirect_to(hub_client_messages_path(client_id: client.id, anchor: "last-item"))
      end
    end
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
end