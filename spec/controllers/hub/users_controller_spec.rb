require "rails_helper"

RSpec.describe Hub::UsersController do
  describe "#profile" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :profile

    context "with an authenticated user" do
      render_views
      let(:accepted_invite_time) { DateTime.new(2015, 2, 11) }
      let(:created_at_time) { DateTime.new(2015, 1, 10) }
      let(:organization) { create :organization, name: "Orange organization" }
      let(:user) do
        create(
          :organization_lead_user,
          name: "Adam Avocado",
          created_at: created_at_time,
          invitation_accepted_at: accepted_invite_time,
          timezone: "America/New_York",
          organization: organization
        )
      end

      before do
        sign_in user
      end

      it "renders information about the current user" do
        get :profile

        expect(response).to be_ok
        expect(response.body).to have_content "Adam Avocado"
        expect(response.body).to have_content "Organization Lead"
        expect(response.body).to have_content "Orange organization"
      end

      context "with a datetime for when the user accepted an invitation" do
        let(:accepted_invite_time) { DateTime.new(2015, 2, 11) }

        it "displays the time the user accepted their invitation" do
          get :profile

          expect(response.body).to have_content "2/10/2015"
        end
      end

      context "without an 'accepted_invite_at' time" do
        let(:accepted_invite_time) { nil }

        it "displays the time the user record was created" do
          get :profile

          expect(response.body).to have_content "1/9/2015"
        end
      end
    end
  end

  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "with an authenticated admin user" do
      render_views

      let!(:leslie) { create :admin_user, name: "Leslie", email: "leslie@example.com" }
      before do
        sign_in create(:admin_user)
        create :user
      end

      it "displays a list of all users and certain key attributes" do
        get :index

        expect(assigns(:users).count).to eq 3
        html = Nokogiri::HTML.parse(response.body)
        expect(html.at_css("#user-#{leslie.id}")).to have_text("leslie@example.com")
        expect(html.at_css("#user-#{leslie.id}")).to have_text("Leslie")
        expect(html.at_css("#user-#{leslie.id}")).to have_text("Admin")
        expect(html.at_css("#user-#{leslie.id} a")["href"]).to eq edit_hub_user_path(id: leslie)
      end

      context "with a suspended user" do
        let!(:suspended_user) { create :user, suspended_at: DateTime.now }

        it "shows that the user is suspended" do
          get :index

          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css("#user-#{suspended_user.id}")).to have_text("Suspended")
        end
      end

      context "invitation acceptance status" do
        let!(:unaccepted_invited_user) { create(:invited_user) }
        let!(:accepted_invite_user) { create(:accepted_invite_user) }

        it "shows the invitation status" do
          get :index

          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css("#user-#{unaccepted_invited_user.id}")).to have_text("Yes")
          expect(html.at_css("#user-#{accepted_invite_user.id}")).not_to have_text("Yes")
        end
      end

      context "with a user whose account is locked" do
        let!(:locked_user) { create :user }
        before { locked_user.lock_access! }

        it "shows that the account is locked" do
          get :index

          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css("#user-#{locked_user.id}")).to have_text("Locked")
        end
      end

      context "with a team member user" do
        let!(:team_member) { create :team_member_user }
        let!(:other_team_member) { create :team_member_user, site: team_member.role.site }
        let!(:site_coordinator) { create :site_coordinator_user, site: team_member.role.site }

        before { sign_in team_member }

        it "only shows edit links for themselves" do
          get :index

          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css("#user-#{team_member.id} a")["href"]).to eq edit_hub_user_path(id: team_member)
          expect(html.at_css("#user-#{other_team_member.id} a")).to be_nil
          expect(html.at_css("#user-#{site_coordinator.id} a")).to be_nil
        end
      end

      context "with a search param" do
        let(:params) do
          { search: "someone@" }
        end
        let!(:first_match) { create :user, email: "someone@example.com" }
        let!(:second_match) { create :user, email: "someone@example.org" }
        let!(:nonmatch) { create :user, email: "else@example.com" }

        it "returns the set of matching users" do
          get :index, params: params

          expect(assigns(:users)).to match_array([first_match, second_match])
        end
      end
    end
  end

  describe "#edit" do
    let!(:user) { create :user, name: "Anne", role: create(:organization_lead_role, organization: create(:organization)) }

    let(:params) { { id: user.id } }
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user editing yourself" do
      before do
        sign_in user
      end

      render_views

      it "shows a form prefilled with data about the user" do
        get :edit, params: params

        expect(response.body).to have_text "Anne"
      end

      it "includes a timezone field in the format users expect" do
        get :edit, params: params

        expect(response.body).to have_text("Eastern Time (US & Canada)")
      end
    end

    context "as an admin user" do
      before do
        sign_in create(:admin_user)
      end

      render_views

      it "renders a page successfully and shows a delete button" do
        get :edit, params: params

        expect(response).to be_ok
        expect(response.body).to have_text "Delete"
      end

      context "editing a locked user" do
        before { user.lock_access! }

        render_views
        it "shows a button to unlock the user's account" do
          get :edit, params: params

          expect(response.body).to have_text "Unlock account"
        end
      end
    end

    context "as an authenticated user editing someone else at the same org" do
      let(:organization) { create(:organization) }

      before do
        other_user = create(:user, role: create(:organization_lead_role, organization: organization))
        sign_in(other_user)
      end

      it "is forbidden" do
        get :edit, params: params

        expect(response).to be_forbidden
      end
    end
  end

  describe "#edit_role" do
    let!(:user) { create :user, name: "Anne", role: create(:organization_lead_role, organization: create(:organization)) }

    let(:params) { { id: user.id, user: { role: "AdminRole" } } }
    it_behaves_like :a_get_action_for_admins_only, action: :edit

    context "as an admin user" do
      before do
        sign_in create(:admin_user)
      end

      it "renders a page successfully and shows the user" do
        get :edit_role, params: params

        expect(response).to be_ok
        expect(assigns(:user)).to eq(user)
      end
    end
  end

  describe "#update_role" do
    let!(:user) { create :user, name: "Anne", role: create(:organization_lead_role, organization: create(:organization)) }

    let(:params) { { id: user.id, user: { role: "AdminRole" } } }
    it_behaves_like :a_post_action_for_admins_only, action: :edit

    context "as an admin user" do
      before do
        sign_in create(:admin_user)
      end

      it "updates the user's role & redirects to the user list" do
        expect { post :update_role, params: params }.to(
          change(AdminRole, :count).by(1).and(
            change(OrganizationLeadRole, :count).by(-1)))

        expect(user.reload.role_type).to eq("AdminRole")

        expect(flash[:notice]).to eq("Updated Anne's role")
        expect(response).to redirect_to edit_hub_user_path(id: user.id)
      end
    end
  end

  describe "#update" do
    let!(:user) { create :organization_lead_user, name: "Anne" }

    let(:params) do
      {
        id: user.id,
        user: {
          timezone: "America/Chicago",
          phone_number: "8324658840"
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "as an authenticated user editing yourself" do
      render_views

      before { sign_in(user) }

      context "when editing user fields that any user can edit about themselves" do
        it "updates the user and redirects to edit" do
          post :update, params: params
          user.reload
          expect(user.timezone).to eq "America/Chicago"
          expect(user.phone_number).to eq "+18324658840"
          expect(response).to redirect_to edit_hub_user_path(id: user)
        end
      end

      context "when the phone number is invalid" do
        render_views
        let(:params) { {
          id: user.id,
          user: {
              timezone: "America/Chicago",
              phone_number: "123456"
          }
        } }
        it "adds errors to the user and renders them on the page" do
          post :update, params: params
          expect(assigns(:user).errors.messages[:phone_number]).to include "Please enter a valid phone number."
          expect(response).to render_template :edit
          expect(response.body).to include "Please enter a valid phone number"
        end
      end

      context "when editing user fields that require admin powers" do
        before do
          params[:user][:is_admin] = true
        end

        it "does not change the user's role" do
          expect { post :update, params: params }.not_to change { user.reload.role }
        end
      end
    end

    context "as an admin" do
      render_views

      before { sign_in(create(:admin_user)) }

      it "can add admin role" do
        params = {
          id: user.id,
          user: {
            is_admin: true,
            timezone: "America/Chicago"
          }
        }
        expect {
          post :update, params: params
        }.to change(OrganizationLeadRole, :count).by(-1).and change(AdminRole, :count).by(1)

        user.reload
        expect(user.role_type).to eq AdminRole::TYPE
      end
    end

    context "as an authenticated user editing someone else at the same org" do
      before do
        other_user = create(:organization_lead_user)
        sign_in(other_user)
      end

      it "is forbidden" do
        get :update, params: params

        expect(response).to be_forbidden
      end
    end
  end

  describe "#resend_invitation" do
    context "with a logged in admin" do
      let!(:resending_user) { create :admin_user }
      let(:original_invited_by_user) { create :admin_user }
      let(:invited_user) { create :user, invited_by: original_invited_by_user }

      before { sign_in resending_user }

      it "updates the invited_by value" do
        put :resend_invitation, params: { user_id: invited_user.id }
          invited_user.reload

          expect(invited_user.invited_by).to eq(resending_user)
        end

      it "updates the invitation_sent_at value" do
        expect {
          put :resend_invitation, params: { user_id: invited_user.id }
          invited_user.reload
        }.to change(invited_user, :invitation_sent_at)
      end

      it "displays an invitation reset flash notice and redirects to the users page" do
        put :resend_invitation, params: { user_id: invited_user.id }
        expect(flash[:notice]).to eq "Invitation re-sent to #{invited_user.email}"
      end

      it "redirects after saving" do
        put :resend_invitation, params: { user_id: invited_user.id }
        expect(flash[:notice]).to eq "Invitation re-sent to #{invited_user.email}"
        expect(response).to redirect_to hub_users_path
      end
    end

    context "with an non-admin user" do
      let!(:resending_user) { create :user }
      let(:invited_user) { create :user }

      before { sign_in resending_user }

      it "does not allow the user to resend an invitation" do
        expect {
          put :resend_invitation, params: { user_id: invited_user.id }
          invited_user.reload
        }.not_to change(invited_user, :invitation_sent_at)
      end
    end
  end

  describe "#unlock" do
    let(:user) { create :user }
    let(:params) do
      { id: user.id }
    end

    it_behaves_like :a_post_action_for_admins_only, action: :unlock

    context "as an admin" do
      before do
        user.lock_access!
        sign_in create(:admin_user)
      end

      it "unlocks the user and redirects to the user index page" do
        patch :unlock, params: params

        expect(user.reload.access_locked?).to eq false
        expect(response).to redirect_to(hub_users_path)
        expect(flash[:notice]).to eq "Unlocked #{user.name}'s account"
      end
    end
  end

  describe "#destroy" do
    let!(:user) { create :team_member_user }
    let(:params) do
      { id: user.id }
    end

    it_behaves_like :a_post_action_for_admins_only, action: :destroy

    context "as an authenticated admin user" do
      before { sign_in create(:admin_user) }

      it "deletes the user and shows a confirmation message" do
        expect do
          delete :destroy, params: params
        end.to change(User, :count).by(-1).and(change(TeamMemberRole, :count).by(-1))

        expect(flash[:notice]).to eq "Deleted #{user.name}'s account"
        expect(response).to redirect_to hub_users_path
      end

      context "when the user has sent a message to a client and has assigned tax returns" do
        let!(:tax_return) { create :tax_return, assigned_user: user }
        before { create :outgoing_text_message, user: user }

        it "suspends the user and unassigns them from all tax returns" do
          delete :destroy, params: params

          expect(user.reload.role).to be_present
          expect(user.suspended_at).to be_present
          expect(tax_return.reload.assigned_user).to be_nil
          expect(tax_return.reload.assigned_user_id).to be_nil
        end

        it "redirects to the users list with a flash message saying the user was suspended" do
          delete :destroy, params: params

          expect(response).to redirect_to hub_users_path
          expect(flash[:notice]).to eq("Suspended #{user.name}'s account")
        end
      end
    end
  end

  describe "#suspend" do
    let!(:user) { create :team_member_user, suspended_at: nil }
    let(:params) do
      { id: user.id }
    end

    it_behaves_like :a_post_action_for_admins_only, action: :suspend

    context "as an authenticated admin user" do
      before { sign_in create(:admin_user) }

      it "suspends the user and shows a confirmation message" do
        patch :suspend, params: params

        expect(user.reload.suspended?).to eq true
        expect(flash[:notice]).to eq "Suspended #{user.name}'s account"
        expect(response).to redirect_to edit_hub_user_path(id: user.id)
      end

      context "when the user has assigned tax returns" do
        let!(:tax_return) { create :tax_return, assigned_user: user }

        it "suspends the user and unassigns them from all tax returns" do
          patch :suspend, params: params

          expect(user.reload.suspended?).to eq true
          expect(tax_return.reload.assigned_user).to be_nil
          expect(tax_return.reload.assigned_user_id).to be_nil
        end
      end
    end
  end

  describe "#unsuspend" do
    let!(:user) { create :team_member_user, suspended_at: DateTime.now }
    let(:params) do
      { id: user.id }
    end

    it_behaves_like :a_post_action_for_admins_only, action: :unsuspend

    context "as an authenticated admin user" do
      before { sign_in create(:admin_user) }

      it "unsuspends the user and shows a confirmation message" do
        patch :unsuspend, params: params

        expect(user.reload.suspended?).to eq false
        expect(flash[:notice]).to eq "Unsuspended #{user.name}'s account"
        expect(response).to redirect_to edit_hub_user_path(id: user.id)
      end
    end
  end
end
