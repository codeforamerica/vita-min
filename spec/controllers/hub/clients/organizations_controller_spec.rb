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

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "as an authenticated organization lead user" do
      before { sign_in user }

      it "can assign to a site in my organiztion" do
        expect {
          patch :update, params: params
          client.reload
        }.to change(client, :vita_partner).from(client.vita_partner).to(site)
         .and change(SystemNote::OrganizationChange, :count).by(1)

        expect(SystemNote.last.user).to eq user

        expect(response).to redirect_to hub_client_path(id: client.id)
      end

      context "when reassigning would remove access for one or more tax return assignees" do
        let(:tax_return_assignee) { create :team_member_user, site: site }
        let(:client) { create :client, vita_partner: site }
        let!(:tax_return) { create :tax_return, client: client, assigned_user: tax_return_assignee }
        let(:params) { { id: client.id, client: { vita_partner_id: other_site.id } } }

        render_views
        it "adds a validation error and does not reassign the client" do
          patch :update, params: params

          expect(response).to be_ok
          expect(client.reload.vita_partner).to eq site
          expect(response).to render_template :edit
          expect(assigns(:client).errors).to include :vita_partner_id
        end
      end

      context "when assigning to an vite partner that you don't have access to" do
        let(:other_org) { create :organization}
        let(:params) { { id: client.id, client: { vita_partner_id: other_org.id } } }

        it "returns a 403" do
          patch :update, params: params

          expect(response).to be_forbidden
        end
      end
    end
  end
end
