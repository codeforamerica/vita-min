require "rails_helper"

RSpec.describe Hub::OrganizationsController, type: :controller do
  let(:parent_coalition) { create :coalition }
  let(:admin_user) { create :admin_user }

  describe "#new" do
    it_behaves_like :a_get_action_for_admins_only, action: :new

    context "as an authenticated admin user" do
      let!(:coalitions) { create_list :coalition, 2 }
      before { sign_in admin_user }

      it "includes coalitions" do
        get :new

        expect(assigns(:coalitions)).to eq coalitions
      end
    end
  end

  describe "#create" do
    let(:params) do
      {
        vita_partner: {
          name: "Orangutan Organization",
          coalition_id: parent_coalition.id
        }
      }
    end

    it_behaves_like :a_post_action_for_admins_only, action: :create

    context "as a logged in admin user" do
      before { sign_in admin_user }

      it "saves a new organization" do
        expect {
          post :create, params: params
        }.to change(VitaPartner.organizations, :count).by 1

        organization = VitaPartner.organizations.last
        expect(organization.name).to eq "Orangutan Organization"
        expect(organization.coalition).to eq parent_coalition
        expect(parent_coalition.organizations).to include organization
        expect(response).to redirect_to(hub_organizations_path)
      end
    end
  end

  describe "#index" do
    it_behaves_like :a_get_action_for_admins_only, action: :index

    context "as a logged in admin user" do
      before { sign_in admin_user }

      let(:organizations) do
        create_list :organization, 5
      end

      it "loads all organizations" do
        get :index

        expect(assigns(:organizations)).to match_array(organizations)
      end
    end
  end

  describe "#edit" do
    let(:organization) { create :organization }
    let(:params) do
      { id: organization.id }
    end

    it_behaves_like :a_get_action_for_admins_only, action: :edit

    context "as an authenticated admin user" do
      render_views

      before do
        sign_in admin_user

        create :site, parent_organization: organization, name: "Salmon Site"
        create :site, parent_organization: organization, name: "Sea Lion Site"
      end

      it "displays a list of existing sites and a link to the site" do
        get :edit, params: params

        expect(response.body).to include "Salmon Site"
        expect(response.body).to include "Sea Lion Site"
        expect(response.body).to include new_hub_site_path(parent_organization_id: organization)
      end
    end
  end

  describe "#update" do
    let(:organization) { create :organization, coalition: parent_coalition }
    let(:new_coalition) { create :coalition, name: "Carrot Coalition" }
    let(:params) do
      {
        id: organization.id,
        vita_partner: {
          coalition_id: new_coalition.id,
          name: "Oregano Organization",
        }
      }
    end

    it_behaves_like :a_post_action_for_admins_only, action: :update

    context "as a logged in admin" do
      before { sign_in admin_user }

      it "updates the name and coalition" do
        post :update, params: params

        organization.reload
        expect(organization.name).to eq "Oregano Organization"
        expect(organization.coalition).to eq new_coalition
        expect(response).to redirect_to(hub_organizations_path)
      end
    end
  end
end
