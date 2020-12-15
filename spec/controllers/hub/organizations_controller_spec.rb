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

  xdescribe "#create" do
    let(:params) do
      {
        organization: {
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

  xdescribe "#index" do
    it_behaves_like :a_get_action_for_admins_only, action: :index

    context "as a logged in admin user" do
      before { sign_in admin_user }
      let(:organizations) do
        create_list :organization, 5
      end

      it "loads all organizations" do
        get :index

        expect(assigns(:organizations)).to eq organizations
      end
    end
  end
end
