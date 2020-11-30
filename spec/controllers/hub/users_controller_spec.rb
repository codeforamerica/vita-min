require "rails_helper"

RSpec.describe Hub::UsersController do
  describe "#profile" do
    let(:vita_partner) { create :vita_partner }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :profile

    context "with an authenticated user" do
      render_views
      let(:user) { create :user_with_lead_membership, name: "Adam Avocado" }
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
      let(:vita_partner) { user.memberships.first.vita_partner }
      let(:user) { create :user_with_lead_membership }
      let!(:leslie) { create :user, name: "Leslie", memberships: [build(:membership, vita_partner: vita_partner)] }
      let!(:ben) { create :user, name: "Ben", memberships: [build(:membership, vita_partner: vita_partner)] }

      before { sign_in user }

      it "displays a list of all users in the org and certain key attributes" do
        get :index
        expect(assigns(:users).count).to eq 3
        html = Nokogiri::HTML.parse(response.body)
        expect(html.at_css("#user-#{leslie.id}")).to have_text("Leslie")
        expect(html.at_css("#user-#{leslie.id}")).to have_text(vita_partner.name)
        expect(html.at_css("#user-#{leslie.id} a")["href"]).to eq edit_hub_user_path(id: leslie)
      end
    end
  end

  describe "#edit" do
    let(:user) { create :user_with_membership }
    let(:vita_partner) { user.memberships.first.vita_partner }
    let!(:other_user) { create :user, name: "Anne", memberships: [build(:membership, vita_partner: vita_partner)] }
    let(:params) { { id: other_user.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      render_views

      before { sign_in(user) }

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
    let!(:user) { create :user, name: "Anne", memberships: [build(:membership, vita_partner: vita_partner)]}
    let(:params) do
      {
        id: user.id,
        user: {
          memberships_attributes: { "0" => { id: user.memberships.first, vita_partner_id: vita_partner.id, role: "member"} },
          timezone: "America/Chicago",
        }
      }
    end
    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "as an authenticated user" do
      render_views

      before { sign_in(create :user, memberships: [build(:membership, vita_partner: vita_partner)]) }

      context "when editing user fields that any user can edit" do
        it "updates the user and redirects to edit" do
          post :update, params: params

          user.reload
          expect(user.memberships.first.vita_partner).to eq vita_partner
          expect(user.timezone).to eq "America/Chicago"
          expect(response).to redirect_to edit_hub_user_path(id: user)
        end
      end

      context "when editing user fields that require admin powers" do
        before do
          params[:user][:is_admin] = true
        end

        it "does not change the user" do
          post :update, params: params

          user.reload
          expect(user.is_admin).to be_falsey
        end
      end

      context "when assigning the user to an organization inaccessible to the current user" do
        before do
          params[:user][:memberships_attributes] = { "0" => { vita_partner_id: create(:vita_partner).id, role: "member" } }
        end

        it "is forbidden" do
          post :update, params: params
          expect(response.status).to eq 403
          expect(user.reload).to eq user
        end
      end
    end

    context "as an admin" do
      render_views

      let(:supported_vita_partner_1) { create(:vita_partner) }
      let(:supported_vita_partner_2) { create(:vita_partner) }

      before { sign_in(create(:admin_user)) }

      it "can add memberships" do
        expect(user.memberships.count).to eq 1

        params = {
          id: user.id,
          user: {
            is_admin: true,
            vita_partner_id: vita_partner.id,
            timezone: "America/Chicago",
            memberships_attributes: {
                "0" => { vita_partner_id: supported_vita_partner_1.id, role: "lead" },
                "1" => { vita_partner_id: supported_vita_partner_2.id, role: "lead" },
                "2" => { vita_partner_id: user.memberships.first.vita_partner.id, role: "member", id: user.memberships.first }
            }
          }
        }

        post :update, params: params

        user.reload
        expect(user.is_admin?).to eq true
        expect(user.memberships.count).to eq 3
        expect(user.memberships).to include(have_attributes(vita_partner_id: vita_partner.id, role: "member"))
        expect(user.memberships).to include(have_attributes(vita_partner_id: supported_vita_partner_1.id, role: "lead"))
        expect(user.memberships).to include(have_attributes(vita_partner_id: supported_vita_partner_2.id, role: "lead"))
      end

      it "can remove memberships" do
        delete_membership = user.memberships.create(vita_partner: supported_vita_partner_2, role: "lead")
        expect(user.memberships.count).to eq 2

        params = {
          id: user.id,
          user: {
            is_admin: false,
            vita_partner_id: vita_partner.id,
            timezone: "America/Chicago",
            memberships_attributes: {
                "0" => { vita_partner_id: vita_partner.id, role: "member", id: user.memberships.first.id },
                "1" => { id: delete_membership.id, _destroy: "1", vita_partner_id: delete_membership.vita_partner_id },
            }
          }
        }

        post :update, params: params

        user.reload
        expect(user.memberships.count).to eq 1
        expect(user.memberships).to include(have_attributes(vita_partner_id: vita_partner.id, role: "member"))
      end

      it "can change supported organizations" do
        old_vita_partner = create(:vita_partner)
        new_vita_partner = create(:vita_partner)
        delete_membership = user.memberships.create(vita_partner: old_vita_partner, role: "lead")

        expect(user.memberships.count).to eq 2
        expect(user.memberships).to include(have_attributes(vita_partner_id: vita_partner.id, role: "member"))
        expect(user.memberships).to include(have_attributes(vita_partner_id: old_vita_partner.id, role: "lead"))

        params = {
          id: user.id,
          user: {
            is_admin: true,
            vita_partner_id: vita_partner.id,
            timezone: "America/Chicago",
            memberships_attributes: {
                "1" => { vita_partner_id: new_vita_partner.id, role: "lead" },
                "2" => { vita_partner_id: vita_partner.id, role: "member", id: user.memberships.first.id },
                "3" => { id: delete_membership.id, _destroy: "1", vita_partner_id: delete_membership.vita_partner.id }
            }
          }
        }

        post :update, params: params

        user.reload
        expect(user.memberships.count).to eq 2
        expect(user.memberships).to include(have_attributes(vita_partner_id: vita_partner.id, role: "member"))
        expect(user.memberships).to include(have_attributes(vita_partner_id: new_vita_partner.id, role: "lead"))
      end
    end
  end
end
