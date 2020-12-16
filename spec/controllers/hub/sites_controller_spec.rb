require "rails_helper"

RSpec.describe Hub::SitesController, type: :controller do
  let(:organization) { create :organization }
  let(:admin_user) { create :admin_user }

  describe "#new" do
    let(:params) do
      { parent_organization_id: organization.id }
    end

    it_behaves_like :a_get_action_for_admins_only, action: :new

    context "as an authenticated admin user" do
      let!(:other_org) { create :organization }
      before { sign_in admin_user }

      it "has a default organization and a list of organizations" do
        get :new, params: params

        expect(assigns(:site).parent_organization).to eq organization
        expect(assigns(:organizations)).to include organization
        expect(assigns(:organizations)).to include other_org
      end
    end
  end

  describe "#create" do
    let(:other_organization) { create :organization }
    let(:params) do
      {
        vita_partner: {
          name: "Library Site",
          parent_organization_id: other_organization.id
        }
      }
    end

    it_behaves_like :a_post_action_for_admins_only, action: :create

    context "as an authenticated admin user" do
      before { sign_in admin_user }

      it "creates the site with attributes and redirects to the organization edit page" do
        expect do
          post :create, params: params
        end.to change { VitaPartner.sites.count }.by 1

        site = VitaPartner.sites.last
        expect(site.name).to eq "Library Site"
        expect(site.parent_organization).to eq other_organization
        expect(response).to redirect_to edit_hub_organization_path(id: other_organization)
      end
    end
  end

  describe "#edit" do
    let!(:other_org) { create :organization }
    let(:site) { create :site, parent_organization: organization }
    let(:params) do
      { parent_organization_id: organization.id, id: site.id }
    end

    it_behaves_like :a_get_action_for_admins_only, action: :new

    context "as an authenticated admin user" do
      before { sign_in admin_user }

      it "retrieves the site, a list of organizations, and returns OK" do
        get :edit, params: params

        expect(assigns(:site)).to eq site
        expect(assigns(:organizations)).to include organization
        expect(assigns(:organizations)).to include other_org
        expect(response).to be_ok
      end
    end
  end

  describe "#update" do
    let(:site) { create :site, parent_organization: organization }
    let(:other_organization) { create :organization }
    let(:params) do
      {
        id: site.id,
        vita_partner: {
          name: "Silly Site",
          parent_organization_id: other_organization.id
        }
      }
    end

    it_behaves_like :a_post_action_for_admins_only, action: :update

    context "as an authenticated admin user" do
      before { sign_in admin_user }

      it "updates the site with the new attributes and redirects to the input organization edit page" do
        post :update, params: params

        site.reload
        expect(site.name).to eq "Silly Site"
        expect(site.parent_organization).to eq other_organization
        expect(response).to redirect_to edit_hub_organization_path(id: other_organization)
      end
    end
  end
end
