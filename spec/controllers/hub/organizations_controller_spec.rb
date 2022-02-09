require "rails_helper"

RSpec.describe Hub::OrganizationsController, type: :controller do
  let(:parent_coalition) { create :coalition }
  let(:user) { create :admin_user }
  let(:form_instance) { instance_double(Hub::OrganizationForm) }

  before do
    allow(form_instance).to receive(:model_name).and_return(Hub::OrganizationForm.new(Organization.new).model_name)
    allow(form_instance).to receive(:errors).and_return([])
  end

  describe "#new" do
    it_behaves_like :a_get_action_for_admins_only, action: :new

    before do
      allow(Hub::OrganizationForm).to receive(:new).and_return(form_instance)
    end

    context "as an authenticated admin user" do
      let!(:coalitions) { create_list :coalition, 2 }
      before { sign_in user }

      it "includes coalitions and the organization form" do
        get :new

        expect(assigns(:coalitions)).to eq coalitions
        expect(assigns(:organization_form)).to eq(form_instance)
      end
    end
  end

  describe "#create" do
    before do
      allow(Hub::OrganizationForm).to receive(:new).and_return(form_instance)
    end

    let(:params) do
      {
        hub_organization_form: {
          name: "Orangutan Organization",
          coalition_id: parent_coalition.id,
          assists_itin_applicants: true
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "as a logged in admin user" do
      before { sign_in user }

      context "when saving the form succeeds" do
        before do
          allow(form_instance).to receive(:save).and_return(true)
        end

        it "redirects to :new" do
          post :create, params: params
          expect(response).to redirect_to(hub_organizations_path)
        end
      end

      context "when saving the form fails" do
        before do
          allow(form_instance).to receive(:save).and_return(false)
        end

        it "re-renders the :new page" do
          post :create, params: params
          expect(response).to render_template(:new)
          expect(assigns(:organization_form)).to eq(form_instance)
        end
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
    end
  end

  describe "#index" do
    let(:coalition) { create :coalition }
    let!(:external_coalition) { create :coalition }
    let!(:external_organization) { create :organization, coalition: external_coalition }
    let!(:organization) { create :organization, coalition: coalition, name: "Org with routing target in AL" }
    let!(:coalition_without_routing_target) { create(:coalition, name: "Coalition with no routing target") }
    let!(:org_without_routing_target) { create :organization, name: "Org with no routing target", coalition: coalition_without_routing_target }
    let!(:independent_org_without_routing_target) { create :organization, name: "Independent org with no routing target" }
    let!(:second_organization) { create :organization, coalition: coalition }
    let!(:site) { create :site, parent_organization: organization }

    before do
      create :state_routing_target, target: coalition, state_abbreviation: "AL"
    end

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :new

    context "as an authenticated user" do
      before { sign_in user }

      context "as a coalition lead user" do
        let(:user) { create :coalition_lead_user, coalition: coalition }

        render_views
        it "shows my coalition and child organizations but no link to add or edit orgs" do
          get :index

          expect(response).to be_ok
          expect(assigns(:presenter)).to be_an_instance_of Hub::OrganizationsPresenter
          expect(response.body).to include hub_organization_path(id: organization)
          expect(response.body).not_to include new_hub_coalition_path
          expect(response.body).not_to include new_hub_organization_path
          expect(response.body).not_to include edit_hub_coalition_path(id: coalition)
          expect(response.body).not_to include edit_hub_organization_path(id: organization)
        end
      end

      context "as a coalition lead user whose coalition has no routing rules" do
        let(:user) { create :coalition_lead_user, coalition: coalition_without_routing_target }

        render_views
        it "shows my coalition and child organizations under 'no state'" do
          get :index

          response_html = Nokogiri::HTML.parse(response.body)
          stateless_element = response_html.at_css("#stateless")
          expect(stateless_element).to have_link(href: hub_coalition_path(id: coalition_without_routing_target))
          expect(stateless_element).to have_link(href: hub_organization_path(id: org_without_routing_target))
        end
      end

      context "as an admin user" do
        let(:user) { create :admin_user }

        render_views

        it "shows links for organization and coalition, and initializes the presenter" do
          get :index

          expect(response).to be_ok
          expect(assigns(:presenter)).to be_an_instance_of Hub::OrganizationsPresenter
          expect(response.body).to include new_hub_organization_path
          expect(response.body).to include new_hub_coalition_path
          expect(response.body).to include edit_hub_organization_path(id: organization)
        end

        it "displays entities without routing rules" do
          get :index

          response_html = Nokogiri::HTML.parse(response.body)
          stateless_element = response_html.at_css("#stateless")
          expect(stateless_element).to have_link(href: edit_hub_organization_path(id: independent_org_without_routing_target))
          expect(stateless_element).to have_link(href: edit_hub_organization_path(id: org_without_routing_target))
          expect(stateless_element).to have_link(href: edit_hub_coalition_path(id: coalition_without_routing_target))
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
        create :vita_partner_zip_code, zip_code: 94606, vita_partner: organization
      end

      it "displays a list of existing sites and a link to the site" do
        get :edit, params: params

        expect(response.body).to include "Salmon Site"
        expect(response.body).to include "Sea Lion Site"
        expect(response.body).to include new_hub_site_path(parent_organization_id: organization)
      end

      it "shows the organization edit form" do
        get :edit, params: params
        expect(assigns(:organization_form)).to be_an_instance_of(Hub::OrganizationForm)
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

      context "zip code routings" do
        it "displays existing routings and prepares the form" do
          get :edit, params: params
          expect(response.body).to include "94606 Oakland, California"

          expect(assigns(:routing_form)).to be_an_instance_of Hub::ZipCodeRoutingForm
        end
      end
    end
  end

  describe "#update" do
    let(:organization) { create :organization, coalition: parent_coalition, capacity_limit: 100, allows_greeters: false }
    let(:source_parameter) { create(:source_parameter, vita_partner: organization, code: "shortlink") }
    let(:new_coalition) { create :coalition, name: "Carrot Coalition" }
    let(:params) do
      {
        id: organization.id,
        hub_organization_form: {
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

    before do
      allow(Hub::OrganizationForm).to receive(:new).and_return(form_instance)
    end

    context "as a logged in admin" do
      before { sign_in user }

      context "when the form is valid and saves successfully" do
        before do
          allow(form_instance).to receive(:save).and_return(true)
        end

        it "redirects to the edit page" do
          post :update, params: params
          expect(response).to redirect_to(edit_hub_organization_path(id: organization.id))
        end
      end

      context "when the form is invalid and does not save successfully" do
        before do
          allow(form_instance).to receive(:save).and_return(false)
        end

        it "re-renders the edit page" do
          post :update, params: params
          expect(response).to be_ok
          expect(response).to render_template(:edit)
          expect(assigns(:organization_form)).to eq(form_instance)
        end
      end
    end
  end

  describe "#suspend_all" do
    let(:organization) { create :organization }
    let(:site) { create :site, parent_organization: organization }
    let!(:team_member_1) { create :user, role: (create :team_member_role, site: site) }
    let!(:team_member_2) { create :user, role: (create :team_member_role, site: site) }
    let!(:team_member_3) { create :user, role: (create :team_member_role, site: site) }
    let(:params) do
      {
        role_type: TeamMemberRole::TYPE,
        id: organization.id
      }
    end

    it_behaves_like :a_post_action_for_admins_only, action: :suspend_all

    context "as a logged in admin" do
      before { sign_in user }

      context "with active team member users" do
        it "updates all users to be suspended" do
          expect(organization.team_members.all?(&:active?)).to eq(true)

          patch :suspend_all, params: params

          expect(organization.team_members.all?(&:suspended?)).to eq(true)
        end
      end
    end
  end

  describe "#activate_all" do
    let(:organization) { create :organization }
    let(:site) { create :site, parent_organization: organization }
    let!(:team_member_1) { create :user, role: (create :team_member_role, site: site), suspended_at: DateTime.now }
    let!(:team_member_2) { create :user, role: (create :team_member_role, site: site), suspended_at: DateTime.now }
    let!(:team_member_3) { create :user, role: (create :team_member_role, site: site), suspended_at: DateTime.now }
    let(:params) do
      {
        role_type: TeamMemberRole::TYPE,
        id: organization.id
      }
    end

    it_behaves_like :a_post_action_for_admins_only, action: :suspend_all

    context "as a logged in admin" do
      before { sign_in user }

      context "with suspended team member users" do
        it "updates all users to be active" do
          expect(organization.team_members.all?(&:suspended?)).to eq(true)

          patch :activate_all, params: params

          expect(organization.team_members.all?(&:active?)).to eq(true)
        end
      end
    end
  end
end
