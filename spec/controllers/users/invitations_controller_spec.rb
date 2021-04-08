require "rails_helper"

RSpec.describe Users::InvitationsController do
  let(:raw_invitation_token) { "exampleToken" }
  let!(:coalition) { create :coalition }
  let!(:vita_partner) { create :vita_partner }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#new" do
    context "as an authenticated admin user" do
      let(:user) { create :admin_user }
      before { sign_in user }

      it "sets @vita_partners and @coalitions so the template can render a list of all groups" do
        get :new

        expect(response).to be_ok
        expect(assigns(:vita_partners)).to include(vita_partner)
        expect(assigns(:coalitions)).to eq [coalition]
      end
    end

    context "as a non-admin user" do
      let(:user) { create :coalition_lead_user }
      let(:coalition_member_organization) { create :organization, coalition: user.role.coalition }
      let(:coalition_member_site) { create :site, parent_organization: coalition_member_organization }
      let!(:inaccessible_site) { create :site }
      before { sign_in user }

      it "sets @vita_partners and @coalitions so the template can render a list of groups the user has access to" do
        get :new

        expect(response).to be_ok
        expect(assigns(:vita_partners)).to match_array([coalition_member_organization, coalition_member_site])
        expect(assigns(:coalitions)).to eq [user.role.coalition]
      end
    end
  end

  describe "#create" do
    it_behaves_like :a_post_action_for_admins_only, action: :create

    context "with an authenticated admin user" do
      let!(:user) { create :admin_user }
      before { sign_in user }

      context "inviting an org lead user" do
        let(:params) do
          {
            user: {
              name: "Cher Cherimoya",
              email: "cherry@example.com",
              role: OrganizationLeadRole::TYPE,
            },
            organization_id: vita_partner.id
          }
        end

        it "creates a new invited org lead user" do
          expect do
            post :create, params: params
          end.to (change(User, :count).by 1).and(change(OrganizationLeadRole, :count).by(1))

          org_lead_role = OrganizationLeadRole.last
          expect(org_lead_role.organization).to eq vita_partner

          invited_user = User.last
          expect(invited_user.role).to eq org_lead_role

          expect(invited_user.name).to eq "Cher Cherimoya"
          expect(invited_user.email).to eq "cherry@example.com"
          expect(invited_user.invitation_token).to be_present
          expect(invited_user.invited_by).to eq user
          expect(response).to redirect_to invitations_path
        end

        context "if the invited user already exists and is an admin" do
          let!(:invited_user) { create :admin_user, email: "cherry@example.com" }

          it "doesn't change the user's role" do
            expect { post :create, params: params }.not_to change { invited_user.reload.role }
            expect(response).to redirect_to invitations_path
          end
        end
      end

      context "inviting a coalition lead user" do
        let(:coalition) { create :coalition }
        let(:params) do
          {
            user: {
              name: "Cher Cherimoya",
              email: "cherry@example.com",
              role: CoalitionLeadRole::TYPE,
            },
            coalition_id: coalition.id
          }
        end

        it "creates a new invited coalition lead user" do
          expect do
            post :create, params: params
          end.to (change(User, :count).by 1).and(change(CoalitionLeadRole, :count).by(1))

          coalition_lead_role = CoalitionLeadRole.last
          expect(coalition_lead_role.coalition).to eq coalition

          invited_user = User.last
          expect(invited_user.role).to eq coalition_lead_role

          expect(invited_user.name).to eq "Cher Cherimoya"
          expect(invited_user.email).to eq "cherry@example.com"
          expect(invited_user.invitation_token).to be_present
          expect(invited_user.invited_by).to eq user
          expect(response).to redirect_to invitations_path
        end
      end

      context "inviting a site coordinator user" do
        let(:site) { create :site }
        let(:params) do
          {
            user: {
              name: "Cher Cherimoya",
              email: "cherry@example.com",
              role: SiteCoordinatorRole::TYPE,
            },
            site_id: site.id
          }
        end

        it "creates a new invited site coordinator user" do
          expect do
            post :create, params: params
          end.to (change(User, :count).by 1).and(change(SiteCoordinatorRole, :count).by(1))

          site_coordinator_role = SiteCoordinatorRole.last
          expect(site_coordinator_role.site).to eq site

          invited_user = User.last
          expect(invited_user.role).to eq site_coordinator_role

          expect(invited_user.name).to eq "Cher Cherimoya"
          expect(invited_user.email).to eq "cherry@example.com"
          expect(invited_user.invitation_token).to be_present
          expect(invited_user.invited_by).to eq user
          expect(response).to redirect_to invitations_path
        end
      end

      context "inviting an admin user" do
        let(:params) do
          {
            user: {
              name: "Adam Apple",
              email: "adam@example.com",
              role: AdminRole::TYPE
            },
          }
        end

        it "creates a new invited admin user" do
          expect do
            post :create, params: params
          end.to (change(User, :count).by 1).and(change(AdminRole, :count).by(1))

          admin_role = AdminRole.last

          invited_user = User.last
          expect(invited_user.role).to eq admin_role

          expect(invited_user.name).to eq "Adam Apple"
          expect(invited_user.email).to eq "adam@example.com"
          expect(invited_user.invitation_token).to be_present
          expect(invited_user.invited_by).to eq user
          expect(response).to redirect_to invitations_path
        end

        context "if the invited user already exists and is an organization lead" do
          let!(:invited_user) { create :organization_lead_user, email: "adam@example.com" }

          it "doesn't change the user's role" do
            expect { post :create, params: params }.not_to change { invited_user.reload.role }
            expect(response).to redirect_to invitations_path
          end
        end
      end

      context "inviting a client success user" do
        let(:params) do
          {
            user: {
              name: "Cleo Squash",
              email: "cleo@example.com",
              role: ClientSuccessRole::TYPE
            },
          }
        end

        it "creates a new invited client success user" do
          expect do
            post :create, params: params
          end.to (change(User, :count).by 1).and(change(ClientSuccessRole, :count).by(1))

          client_success_role = ClientSuccessRole.last

          invited_user = User.last
          expect(invited_user.role).to eq client_success_role

          expect(invited_user.name).to eq "Cleo Squash"
          expect(invited_user.email).to eq "cleo@example.com"
          expect(invited_user.invitation_token).to be_present
          expect(invited_user.invited_by).to eq user
          expect(response).to redirect_to invitations_path
        end
      end

      context "inviting a greeter" do
        let(:params) do
          {
            user: {
              name: "Gary Guava",
              email: "gary@example.com",
              role: GreeterRole::TYPE,
            }
          }
        end

        it "creates a new invited greeter user" do
          expect do
            post :create, params: params
          end.to (change(User, :count).by 1).and(change(GreeterRole, :count).by(1))

          greeter_role = GreeterRole.last

          invited_user = User.last
          expect(invited_user.role).to eq greeter_role

          expect(invited_user.name).to eq "Gary Guava"
          expect(invited_user.email).to eq "gary@example.com"
          expect(invited_user.invitation_token).to be_present
          expect(invited_user.invited_by).to eq user
          expect(response).to redirect_to invitations_path
        end
      end

      context "inviting a team member user" do
        let(:site) { create(:site) }
        let(:params) do
          {
            user: {
              name: "Cher Cherimoya",
              email: "cherry@example.com",
              role: TeamMemberRole::TYPE,
            },
            site_id: site.id
          }
        end

        it "creates a new invited team member user" do
          expect do
            post :create, params: params
          end.to (change(User, :count).by 1).and(change(TeamMemberRole, :count).by(1))

          role = TeamMemberRole.last
          expect(role.site).to eq site

          invited_user = User.last
          expect(invited_user.role).to eq role

          expect(invited_user.name).to eq "Cher Cherimoya"
          expect(invited_user.email).to eq "cherry@example.com"
          expect(invited_user.invitation_token).to be_present
          expect(invited_user.invited_by).to eq user
          expect(response).to redirect_to invitations_path
        end
      end
    end
  end

  describe "#edit" do
    render_views

    let(:user) { create :admin_user }
    let(:params) { { invitation_token: raw_invitation_token } }
    let!(:invited_user) do
      create(
        :invited_user,
        name: "Cherry Cherimoya",
        email: "cherry@example.com",
        invitation_token: Devise.token_generator.digest(User, :invitation_token, raw_invitation_token),
        invited_by: user,
        role: create(:organization_lead_role, organization: vita_partner)
      )
    end

    it "shows the user's existing information" do
      get :edit, params: params

      expect(response.body).to have_content "cherry@example.com"
      expect(response.body).to have_content vita_partner.name
      expect(assigns(:user).name).to eq "Cherry Cherimoya"
    end

    it "includes a timezone field in the format users expect" do
      get :edit, params: params

      expect(response.body).to have_text("Eastern Time (US & Canada)")
    end

    context "with a HEAD request" do
      # one of our collaborators encountered this error, unclear why the browser used HEAD, but it happens
      it "works fine and shows the user's info" do
        head :edit, params: params

        expect(response.body).to have_content "cherry@example.com"
        expect(response.body).to have_content vita_partner.name
        expect(assigns(:user).name).to eq "Cherry Cherimoya"
      end
    end

    context "without a matching token" do
      let(:params) { { invitation_token: "BrokenToken" } }

      it "shows an error page" do
        get :edit, params: params

        expect(response).to be_not_found
        expect(response.body).to have_content "We can't find that invitation"
      end
    end

    context "without a token" do
      it "shows an error page" do
        get :edit

        expect(response).to be_not_found
        expect(response.body).to have_content "We can't find that invitation"
      end
    end
  end

  describe "#update" do
    let!(:invited_user) do
      create(
        :invited_user,
        name: "Cherry Cherimoya",
        invitation_token: Devise.token_generator.digest(User, :invitation_token, raw_invitation_token),
      )
    end

    context "with valid params" do
      let(:params) do
        {
          user: {
            name: "Cher Cherimoya",
            password: "secret password",
            password_confirmation: "secret password",
            invitation_token: raw_invitation_token,
            timezone: "America/Los_Angeles",
          }
        }
      end

      it "updates all necessary information on the user and signs them in" do
        expect do
          post :update, params: params
        end.to change { controller.current_user }.from(nil).to(invited_user)
        invited_user.reload
        expect(invited_user.name).to eq "Cher Cherimoya"
        expect(invited_user.timezone).to eq "America/Los_Angeles"
        expect(response).to redirect_to hub_user_profile_path
      end
    end

    context "with missing required fields" do
      let(:params) do
        {
          user: {
            name: "",
            password: "secret password",
            password_confirmation: "secret password",
            invitation_token: raw_invitation_token
          }
        }
      end

      it "shows a validation error" do
        post :update, params: params

        expect(assigns(:user).errors).to include :name
        expect(response.status).to eq 200
      end
    end
  end
end
