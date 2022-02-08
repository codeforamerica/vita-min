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
        site: {
          name: "Library Site",
          parent_organization_id: other_organization.id,
          accepts_itin_applicants: true
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
        expect(site.accepts_itin_applicants).to eq true
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

    it_behaves_like :a_get_action_for_admins_only, action: :edit

    context "as an authenticated admin user" do
      before do
        create :vita_partner_zip_code, zip_code: 94606, vita_partner: site
        sign_in admin_user
      end

      it "retrieves the site, a list of organizations, and returns OK" do
        get :edit, params: params

        expect(assigns(:site)).to eq site
        expect(assigns(:organizations)).to include organization
        expect(assigns(:organizations)).to include other_org
        expect(response).to be_ok
      end

      context "with SourceParameters for this site" do
        before do
          create(:source_parameter, code: "shortlink1", vita_partner: site)
          create(:source_parameter, code: "shortlink2", vita_partner: site)
        end

        render_views

        it "displays the link names" do
          get :edit, params: params

          expect(response.body).to include("shortlink1")
          expect(response.body).to include("shortlink2")
        end
      end

      context "zip code routings" do
        render_views
        it "displays existing routings and prepares the form" do
          get :edit, params: params
          expect(response.body).to include "94606 Oakland, California"

          expect(assigns(:routing_form)).to be_an_instance_of Hub::ZipCodeRoutingForm
        end
      end
    end
  end

  describe "#update" do
    let(:source_parameter) { create(:source_parameter, vita_partner: site, code: "shortlink") }
    let(:site) { create :site, parent_organization: organization }
    let(:other_organization) { create :organization }
    let(:params) do
      {
        id: site.id,
        site: {
          name: "Silly Site",
          parent_organization_id: other_organization.id,
          timezone: "America/Chicago",
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

    context "as an authenticated admin user" do
      before { sign_in admin_user }

      context "when site object is valid" do
        it "updates the site with the new attributes and reloads page." do
          post :update, params: params

          site.reload
          expect(site.name).to eq "Silly Site"
          expect(site.parent_organization).to eq other_organization
          expect(site.timezone).to eq "America/Chicago"
          expect { source_parameter.reload }.to raise_error ActiveRecord::RecordNotFound
          expect(site.source_parameters.pluck(:code)).to eq(["newshortlink"])
          expect(flash[:notice]).to eq "Changes saved"
          expect(response).to redirect_to edit_hub_site_path(id: site.id)
        end
      end

      context "when the site object is not valid" do
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
