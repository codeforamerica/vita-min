require "rails_helper"

RSpec.describe Hub::UsersController do
  describe "#profile" do
    let(:vita_partner) { create :vita_partner }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :profile

    context "with an authenticated user" do
      render_views
      let(:user) { create :user_with_org, role: "agent", name: "Adam Avocado", vita_partner: vita_partner}
      before { sign_in user }

      it "renders information about the current user with helpful links" do
        get :profile

        expect(response).to be_ok
        expect(response.body).to have_content "Adam Avocado"
        expect(response.body).to include invitations_path
        expect(response.body).to include hub_clients_path
        expect(response.body).to include hub_users_path
      end
    end
  end

  describe "#index" do

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :profile

    context "with an authenticated user" do
      render_views

      before { sign_in(create :user_with_org, vita_partner: vita_partner ) }
      let(:vita_partner) { create :vita_partner, name: "Pawnee Preparers" }
      let!(:leslie) { create :zendesk_admin_user, name: "Leslie", vita_partner: vita_partner, is_admin: true, is_client_support: true }
      let!(:ben) { create :agent_user, name: "Ben", vita_partner: vita_partner }

      it "displays a list of all users in the org and certain key attributes" do
        get :index

        expect(assigns(:users).count).to eq 3
        html = Nokogiri::HTML.parse(response.body)
        expect(html.at_css("#user-#{leslie.id}")).to have_text("Leslie")
        expect(html.at_css("#user-#{leslie.id}")).to have_text("Pawnee Preparers")
        expect(html.at_css("#user-#{leslie.id}")).to have_text("Admin, Client support")
        expect(html.at_css("#user-#{leslie.id} a")["href"]).to eq edit_hub_user_path(id: leslie)
      end
    end
  end

  describe "#edit" do
    let(:vita_partner) { create :vita_partner }
    let!(:user) { create :agent_user, name: "Anne", vita_partner: vita_partner }
    let(:params) { { id: user.id } }
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      render_views

      before { sign_in(create :user_with_org, vita_partner: vita_partner) }

      it "shows a form prefilled with data about the user" do
        get :edit, params: params

        expect(response.body).to have_text "Anne"
      end

      it "includes a timezone field in the format users expect" do
        get :edit, params: params

        expect(response.body).to have_text("Eastern Time (US & Canada)")
      end
    end
  end

  describe "#update" do
    let!(:vita_partner) { create :vita_partner, name: "Avonlea Tax Aid" }
    let!(:user) { create :agent_user, name: "Anne", vita_partner: vita_partner }
    let(:params) do
      {
        id: user.id,
        user: {
          vita_partner_id: vita_partner.id,
          timezone: "America/Chicago",
        }
      }
    end
    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "as an authenticated user" do
      render_views

      before { sign_in(create :user_with_org, vita_partner: vita_partner) }

      context "when editing user fields that any user can edit" do
        it "updates the user and redirects to edit" do
          post :update, params: params

          user.reload
          expect(user.vita_partner).to eq vita_partner
          expect(user.timezone).to eq "America/Chicago"
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

      context "when assigning the user to an organization inaccessible to the current user" do
        before do
          params[:user][:vita_partner_id] = create(:vita_partner).id
        end

        it "raises an exception and does not change the user" do
          expect do
            post :update, params: params
          end.to raise_error(ActiveRecord::RecordNotFound)
          expect(user.reload).to eq user
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
            vita_partner_id: vita_partner.id,
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
            vita_partner_id: vita_partner.id
          }
        }

        post :update, params: params

        user.reload
        expect(user.is_client_support?).to eq true
      end
    end
  end
end
