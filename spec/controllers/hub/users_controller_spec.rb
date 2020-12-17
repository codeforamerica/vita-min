require "rails_helper"

RSpec.describe Hub::UsersController do
  describe "#profile" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :profile

    context "with an authenticated user" do
      render_views
      let(:user) { create :user_with_org, name: "Adam Avocado" }

      before do
        create :organization_lead_role, user: user
        sign_in user
      end

      it "renders information about the current user with helpful links" do
        get :profile

        expect(response).to be_ok
        expect(response.body).to have_content "Adam Avocado"
        expect(response.body).to have_content "Organization lead"
        expect(response.body).to include invitations_path
        expect(response.body).to include hub_clients_path
        expect(response.body).to include hub_users_path
      end
    end
  end

  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "with an authenticated user" do
      let(:vita_partner) { create :vita_partner }
      let(:user) { create(:user, vita_partner: vita_partner) }
      before do
        sign_in user
        create :user, vita_partner: vita_partner
      end

      it "displays only the user who is logged in" do
        get :index

        expect(assigns(:users)).to eq [user]
      end
    end

    context "with an authenticated admin user" do
      render_views

      let!(:leslie) { create :admin_user, name: "Leslie", vita_partner: create(:vita_partner, name: "Pawnee Preparers") }
      before do
        sign_in create(:admin_user)
        create :user
      end

      it "displays a list of all users and certain key attributes" do
        get :index

        expect(assigns(:users).count).to eq 3
        html = Nokogiri::HTML.parse(response.body)
        expect(html.at_css("#user-#{leslie.id}")).to have_text("Leslie")
        expect(html.at_css("#user-#{leslie.id}")).to have_text("Pawnee Preparers")
        expect(html.at_css("#user-#{leslie.id}")).to have_text("Admin")
        expect(html.at_css("#user-#{leslie.id} a")["href"]).to eq edit_hub_user_path(id: leslie)
      end
    end
  end

  describe "#edit" do
    let!(:user) { create :user, name: "Anne", vita_partner: create(:vita_partner) }
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
      before { sign_in(create(:user, vita_partner: user.vita_partner)) }

      it "is forbidden" do
        get :edit, params: params

        expect(response).to be_forbidden
      end
    end
  end

  describe "#update" do
    let!(:vita_partner) { create :vita_partner, name: "Avonlea Tax Aid" }
    let!(:user) { create :user, name: "Anne", vita_partner: vita_partner }
    let(:params) do
      {
        id: user.id,
        user: {
          timezone: "America/Chicago",
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

          expect(user.reload.timezone).to eq "America/Chicago"
          expect(response).to redirect_to edit_hub_user_path(id: user)
        end
      end

      context "when editing user fields that require admin powers" do
        before do
          params[:user][:supported_organizations] = [create(:vita_partner).id]
          params[:user][:is_admin] = true
        end

        it "does not change the user" do
          post :update, params: params

          user.reload
          expect(user.is_admin).to be_falsey
          expect(user.supported_organization_ids).to be_empty
        end
      end
    end

    context "as an admin" do
      render_views

      let(:supported_vita_partner_1) { create(:vita_partner) }
      let(:supported_vita_partner_2) { create(:vita_partner) }

      before { sign_in(create(:admin_user, supported_organizations: [supported_vita_partner_1, supported_vita_partner_2])) }

      it "can add admin role & supported organizations" do
        params = {
          id: user.id,
          user: {
            is_admin: true,
            timezone: "America/Chicago",
            supported_organization_ids: [
              supported_vita_partner_1.id,
              supported_vita_partner_2.id
            ]
          }
        }

        post :update, params: params

        user.reload
        expect(user.is_admin?).to eq true
        expect(user.supported_organization_ids.sort).to eq [supported_vita_partner_1.id, supported_vita_partner_2.id]
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
      before { sign_in(create(:user, vita_partner: user.vita_partner)) }

      it "is forbidden" do
        get :update, params: params

        expect(response).to be_forbidden
      end
    end
  end
end
