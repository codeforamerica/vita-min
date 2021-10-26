require 'rails_helper'

RSpec.describe Hub::Clients::OrganizationsController, type: :controller do
  let(:organization) { create :organization }
  let!(:site) { create :site, parent_organization: organization }
  let!(:other_site) { create :site, parent_organization: organization }
  let!(:client) { create :client, vita_partner: organization }
  let!(:intake) { create :intake, client: client }
  let(:user) { create :organization_lead_user, organization: organization }

  describe "#edit" do
    let(:params) { { id: client.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated organization lead user" do
      before { sign_in user }

      it "allows me to choose between all the orgs and sites I can access" do
        get :edit, params: params

        expect(assigns(:vita_partners)).to match_array([organization, site, other_site])
      end
    end
  end

  describe "#update" do
    let(:params) { { id: client.id, client: { vita_partner_id: site.id } } }
    let(:instance) { instance_double(UpdateClientVitaPartnerService) }
    let(:double_class) { class_double(UpdateClientVitaPartnerService).as_stubbed_const }

    before do
      allow(double_class).to receive(:new).and_return(instance)
      allow(instance).to receive(:update!)
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "as an authenticated organization lead user" do
      before do
        sign_in user
      end

      it "calls the UpdateClientVitaPartnerService service and redirects" do
        patch :update, params: params

        expect(instance).to have_received(:update!).once
        expect(response).to redirect_to hub_client_path(id: client.id)
      end

      context "when assigning to an vita partner that you don't have access to" do
        let(:other_org) { create :organization }
        let(:params) { { id: client.id, client: { vita_partner_id: other_org.id } } }

        it "returns a 403" do
          patch :update, params: params
          expect(response).to be_forbidden
        end
      end

      context "when something goes wrong in the service call" do
        before do
          allow(instance).to receive(:update!).and_raise(ActiveRecord::Rollback)
        end

        it "rescues the ActiveRecord::Rollback and returns a 300" do
          patch :update, params: params
          expect(response).to render_template :edit
        end
      end
    end
  end
end
