require "rails_helper"

RSpec.describe Hub::UsersController do
  describe "#profile" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :profile

    context "with an authenticated user" do
      render_views
      let(:accepted_invite_time) { DateTime.new(2015, 2, 11) }
      let(:created_at_time) { DateTime.new(2015, 1, 10) }
      let(:user) do
        create(
          :user,
          name: "Adam Avocado",
          created_at: created_at_time,
          invitation_accepted_at: accepted_invite_time,
          timezone: "America/New_York",
          role: create(:organization_lead_role, organization: (create :organization, name: "Orange organization"))
        )
      end

      before do
        sign_in user
      end

      it "renders information about the current user with helpful links" do
        get :profile

        expect(response).to be_ok
        expect(response.body).to have_content "Adam Avocado"
        expect(response.body).to have_content "Organization lead"
        expect(response.body).to have_content "Orange organization"
        expect(response.body).to include invitations_path
        expect(response.body).to include hub_clients_path
        expect(response.body).to include hub_users_path
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

      let!(:leslie) { create :admin_user, name: "Leslie" }
      before do
        sign_in create(:admin_user)
        create :user
      end

      it "displays a list of all users and certain key attributes" do
        get :index

        expect(assigns(:users).count).to eq 3
        html = Nokogiri::HTML.parse(response.body)
        expect(html.at_css("#user-#{leslie.id}")).to have_text("Leslie")
        expect(html.at_css("#user-#{leslie.id}")).to have_text("Admin")
        expect(html.at_css("#user-#{leslie.id} a")["href"]).to eq edit_hub_user_path(id: leslie)
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

      it "returns 200 OK" do
        get :edit, params: params

        expect(response).to be_ok
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
        expect(user.role_type).to eq "AdminRole"
      end

      it "can add client support role" do
        params = {
          id: user.id,
          user: {
            is_client_support: true,
          }
        }

        post :update, params: params

        user.reload
        expect(user.is_client_support?).to eq true
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
end
