require "rails_helper"

RSpec.describe Hub::OrganizationsController, type: :controller do
  let(:parent_coalition) { create :coalition }
  let(:user) { create :admin_user }

  describe "#new" do
    it_behaves_like :a_get_action_for_admins_only, action: :new

    context "as an authenticated admin user" do
      let!(:coalitions) { create_list :coalition, 2 }
      before { sign_in user }

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

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "as a logged in admin user" do
      before { sign_in user }

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

  describe "#show" do
    let(:organization) { create :organization }
    let!(:site) { create :site, parent_organization: organization }
    let!(:second_site) { create :site, parent_organization: organization }
    let(:params) do
      { id: organization.id }
    end

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show

    context "as an authenticated organization lead" do
      let(:user) { create :organization_lead_user, organization: organization }
      before { sign_in user }
      it "shows the sites in my organization" do
        get :show, params: params

        expect(response.status).to eq 200
        expect(assigns(:sites)).to match_array [site, second_site]
      end


      context "with a site id" do
        let(:params) { { id: site.id } }

        it "is not found" do
          expect do
            get :show, params: params
          end.to raise_error(ActiveRecord::RecordNotFound) # in deployment configs, this would be a 404
        end
      end
    end
  end


  describe "#index" do
    let(:coalition) { create :coalition}
    let!(:external_coalition) { create :coalition }
    let!(:external_organization) { create :organization, coalition: external_coalition }
    let!(:organization) { create :organization, coalition: coalition }
    let!(:second_organization) { create :organization, coalition: coalition }
    let!(:site) { create :site, parent_organization: organization }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :new

    context "as an authenticated user" do
      before { sign_in user }

      context "as a coalition lead user" do
        let(:user) { create :coalition_lead_user, coalition: coalition }

        render_views
        it "shows my coalition and child organizations but no link to add or edit orgs" do
          get :index

          expect(response).to be_ok
          expect(assigns(:coalitions)).to match_array [coalition]
          expect(assigns(:organizations)).to match_array [organization, second_organization]
          expect(response.body).to include hub_organization_path(id: organization)
          expect(response.body).not_to include new_hub_organization_path
          expect(response.body).not_to include edit_hub_organization_path(id: organization)
        end
      end

      context "as an admin user " do
        let(:user) { create :admin_user }

        render_views
        it "shows all coalitions and organizations, with a link to add a new org" do
          get :index

          expect(response).to be_ok
          expect(assigns(:coalitions)).to match_array [coalition, external_coalition]
          expect(assigns(:organizations)).to match_array VitaPartner.organizations.all
          expect(response.body).to include new_hub_organization_path
        end
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
        sign_in user

        create :site, parent_organization: organization, name: "Salmon Site"
        create :site, parent_organization: organization, name: "Sea Lion Site"
      end

      it "displays a list of existing sites and a link to the site" do
        get :edit, params: params

        expect(response.body).to include "Salmon Site"
        expect(response.body).to include "Sea Lion Site"
        expect(response.body).to include new_hub_site_path(parent_organization_id: organization)
      end

      context "with SourceParameters for this org" do
        before do
          create(:source_parameter, code: "shortlink1", vita_partner: organization)
          create(:source_parameter, code: "shortlink2", vita_partner: organization)
        end

        it "displays the link names" do
          get :edit, params: params

          expect(response.body).to include("shortlink1")
          expect(response.body).to include("shortlink2")
        end
      end
    end
  end

  describe "#update" do
    let(:organization) { create :organization, coalition: parent_coalition, capacity_limit: 100 }
    let(:source_parameter) { create(:source_parameter, vita_partner: organization, code: "shortlink") }
    let(:new_coalition) { create :coalition, name: "Carrot Coalition" }
    let(:params) do
      {
        id: organization.id,
        vita_partner: {
          coalition_id: new_coalition.id,
          name: "Oregano Organization",
          timezone: "America/Chicago",
          capacity_limit: "200",
          allows_greeters: "true",
          source_parameters_attributes: {
            "0": {
              id: source_parameter.id.to_s,
              _destroy: true,
              code: "shortlink",
            },
            "1": {
              code: "newshortlink",
            }
          }
        }
      }
    end

    it_behaves_like :a_post_action_for_admins_only, action: :update

    context "as a logged in admin" do
      before { sign_in user }

      context "the organization object is valid" do
        it "updates the name and coalition and source parameters" do
          post :update, params: params

          organization.reload
          expect(organization.name).to eq "Oregano Organization"
          expect(organization.coalition).to eq new_coalition
          expect(organization.timezone).to eq "America/Chicago"
          expect(organization.capacity_limit).to eq 200
          expect(organization.allows_greeters).to eq true
          expect(response).to redirect_to(edit_hub_organization_path(id: organization.id))
          expect(SourceParameter.find_by(code: "shortlink")).to be_nil
          expect(organization.reload.source_parameters.pluck(:code)).to eq(["newshortlink"])
        end
      end

      context "the organization object is not valid" do
        before do
          allow_any_instance_of(VitaPartner).to receive(:update).and_return false
        end

        it "re-renders edit with an error message" do
          post :update, params: params

          expect(flash.now[:alert]).to eq "Please fix indicated errors and try again."
          expect(response).to render_template :edit
        end
      end
    end
  end
end
