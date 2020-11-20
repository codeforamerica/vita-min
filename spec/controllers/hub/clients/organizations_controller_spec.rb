require 'rails_helper'

RSpec.describe Hub::Clients::OrganizationsController, type: :controller do
  describe "#update" do
    let!(:client) {create :client, vita_partner: (create :vita_partner) }
    let!(:new_vita_partner) { create :vita_partner}
    let(:params) { {id: client.id, client: { vita_partner_id: new_vita_partner.id}} }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "as a logged in user with access to the clients organization" do
      let!(:user) { create :user }

      before do
        sign_in user
        allow_any_instance_of(Ability).to receive(:can?).with(:update, VitaPartner).and_return(true)
        allow_any_instance_of(Ability).to receive(:can?).with(:update, Client).and_return(true)
        allow_any_instance_of(Ability).to receive(:can?).with(:edit_organization, Client).and_return(true)

      end

      it "can change the associated organization on a client" do
        expect {
          patch :update, params: params
          client.reload
        }.to change(client, :vita_partner).from(client.vita_partner).to(new_vita_partner)

        expect(response).to redirect_to hub_client_path(id: client.id)
      end
    end

    context "as a logged in user without access to the clients organization" do
      let!(:user) { create :user, vita_partner: (create :vita_partner) }
      before { sign_in user }

      it "does not allow user to update" do
        patch :update, params: params
        expect(response.status).to eq 403
      end
    end

    describe "#edit" do
      let!(:client) { create :client, vita_partner: (create :vita_partner) }
      let!(:new_vita_partner) { create :vita_partner }
      let(:params) { {id: client.id, client: { vita_partner_id: new_vita_partner.id}} }

      it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    end
  end
end