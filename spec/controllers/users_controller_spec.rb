require "rails_helper"

RSpec.describe UsersController do
  describe "#profile" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :profile
    it_behaves_like :a_get_action_for_beta_testers_only, action: :profile

    context "with an authenticated beta tester" do
      render_views
      let(:user) { create :beta_tester, role: "agent", name: "Adam Avocado" }
      before { sign_in user }

      it "renders information about the current user with helpful links" do
        get :profile

        expect(response).to be_ok
        expect(response.body).to have_content "Adam Avocado"
        expect(response.body).to include invitations_path
        expect(response.body).to include case_management_clients_path
        expect(response.body).to include users_path
      end
    end
  end

  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :profile
    it_behaves_like :a_get_action_for_beta_testers_only, action: :profile

    context "with an authenticated beta tester" do
      render_views

      before { sign_in(create :beta_tester, role: "admin") }
      let(:vita_partner) { create :vita_partner, name: "Pawnee Preparers" }
      let!(:leslie) { create :admin_user, name: "Leslie", vita_partner: vita_partner }
      let!(:ben) { create :agent_user, name: "Ben", vita_partner: vita_partner }
      let!(:ron) { create :agent_user, name: "Ron", is_beta_tester: true }

      it "displays a list of all users with certain key attributes" do
        get :index

        expect(assigns(:users).count).to eq 4
        html = Nokogiri::HTML.parse(response.body)
        expect(html.at_css("#user-#{leslie.id}")).to have_text("Leslie")
        expect(html.at_css("#user-#{leslie.id}")).to have_text("Admin")
        expect(html.at_css("#user-#{leslie.id}")).to have_text("Pawnee Preparers")
        expect(html.at_css("#user-#{leslie.id} a")["href"]).to eq edit_user_path(id: leslie)
        expect(html.at_css("#user-#{ron.id}")).to have_text("Ron (beta-tester)")
        expect(html.at_css("#user-#{ron.id}")).to have_text("None")
      end
    end
  end

  describe "#edit" do
    let!(:user) { create :agent_user, name: "Anne" }
    let(:params) { { id: user.id } }
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit
    it_behaves_like :a_get_action_for_beta_testers_only, action: :edit

    context "as an authenticated beta tester" do
      render_views

      before { sign_in(create :beta_tester) }

      it "shows a form prefilled with data about the user" do
        get :edit, params: params

        expect(response.body).to have_text "Anne"
      end

      it "includes a timezone field in the format users expect" do
        get :edit, params: params

        expect(response.body).to have_text("Eastern Time (US & Canada)")
      end

      it "lists all US timezones in a variable for the template" do
        get :edit, params: params

        expect(assigns(:timezone_options)).to include(["Pacific Time (US & Canada)", "America/Los_Angeles"])
      end
    end
  end

  describe "#update" do
    let!(:vita_partner) { create :vita_partner, name: "Avonlea Tax Aid" }
    let!(:user) { create :agent_user, name: "Anne" }
    let(:params) do
      {
        id: user.id,
        user: {
          is_beta_tester: true,
          vita_partner_id: vita_partner.id,
          timezone: "America/Chicago",
        }
      }
    end
    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update
    it_behaves_like :a_post_action_for_beta_testers_only, action: :update

    context "as an authenticated beta tester" do
      render_views

      before { sign_in(create :beta_tester) }

      it "updates the user and redirects to edit" do
        post :update, params: params

        user.reload
        expect(user.is_beta_tester?).to eq true
        expect(user.vita_partner).to eq vita_partner
        expect(user.timezone).to eq "America/Chicago"
        expect(response).to redirect_to edit_user_path(id: user)
      end
    end
  end
end
