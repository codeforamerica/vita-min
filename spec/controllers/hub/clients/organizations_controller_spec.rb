require 'rails_helper'

RSpec.describe Hub::Clients::OrganizationsController, type: :controller do
  describe "#update" do
    let!(:client) { create :client, vita_partner: create(:vita_partner) }
    let!(:new_vita_partner) { create :vita_partner }
    let(:params) { { id: client.id, client: { vita_partner_id: new_vita_partner.id } } }

    it_behaves_like :a_post_action_for_admins_only, action: :update

    context "as a logged in admin user" do
      before { sign_in create(:admin_user) }

      it "can change the associated organization on a client" do
        expect {
          patch :update, params: params
          client.reload
        }.to change(client, :vita_partner).from(client.vita_partner).to(new_vita_partner)

        expect(response).to redirect_to hub_client_path(id: client.id)
      end
    end

    describe "#edit" do
      let(:params) { { id: create(:client).id } }

      it_behaves_like :a_get_action_for_admins_only, action: :edit
    end
  end
end
