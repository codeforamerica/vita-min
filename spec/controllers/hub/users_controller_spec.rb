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

      it "assigns user vita_partner id to the member membership vita_partner_id" do
        get :edit, params: params
        expect(assigns(:user).vita_partner_id).to eq vita_partner.id
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
          vita_partner_id: vita_partner.id,
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

      context "when creating lead memberships to inaccessible organization" do
        before do
          params[:user][:vita_partner_id] = vita_partner.id
          params[:user][:supported_organization_ids] = [create(:vita_partner).id, create(:vita_partner).id]
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

      before { sign_in(create(:admin_user)) }

      it "can add admin role & organization memberships" do
        expect(user.memberships.count).to eq 1

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
        expect(user.memberships.count).to eq 3
        expect(user.memberships).to include(have_attributes(vita_partner_id: vita_partner.id, role: "member"))
        expect(user.memberships).to include(have_attributes(vita_partner_id: supported_vita_partner_1.id, role: "lead"))
        expect(user.memberships).to include(have_attributes(vita_partner_id: supported_vita_partner_2.id, role: "lead"))
      end

      it "can remove memberships" do
        user.memberships.create(vita_partner: supported_vita_partner_2, role: "lead")
        expect(user.memberships.count).to eq 2

        params = {
          id: user.id,
          user: {
            is_admin: true,
            vita_partner_id: vita_partner.id,
            timezone: "America/Chicago",
            supported_organization_ids: []
          }
        }

        post :update, params: params

        user.reload
        expect(user.is_admin?).to eq true
        expect(user.memberships.count).to eq 1
        expect(user.memberships).to include(have_attributes(vita_partner_id: vita_partner.id, role: "member"))
      end

      it "can change supported organizations" do
        old_vita_partner = create(:vita_partner)
        new_vita_partner = create(:vita_partner)
        user.memberships.create(vita_partner: old_vita_partner, role: "lead")

        expect(user.memberships.count).to eq 2
        expect(user.memberships).to include(have_attributes(vita_partner_id: vita_partner.id, role: "member"))
        expect(user.memberships).to include(have_attributes(vita_partner_id: old_vita_partner.id, role: "lead"))

        params = {
          id: user.id,
          user: {
            is_admin: true,
            vita_partner_id: vita_partner.id,
            timezone: "America/Chicago",
            supported_organization_ids: [new_vita_partner.id]
          }
        }

        post :update, params: params

        user.reload
        expect(user.memberships.count).to eq 2
        expect(user.memberships).to include(have_attributes(vita_partner_id: vita_partner.id, role: "member"))
        expect(user.memberships).to include(have_attributes(vita_partner_id: new_vita_partner.id, role: "lead"))
      end

      it "omits bad supported organization ids" do
        user = create :user, memberships: [build(:membership, vita_partner: vita_partner)]
        params = { id: user.id, user: { vita_partner_id: vita_partner.id, supported_organization_ids: ["", nil] } }

        put :update, params: params

        user.reload
        expect(user.memberships.length).to eq 1
        expect(user.memberships).to include(have_attributes(vita_partner_id: vita_partner.id, role: "member"))
      end

      it "does not persist vita_partner_id to user" do
        new_vita_partner = create(:vita_partner)
        params = { id: user.id, user: { vita_partner_id: new_vita_partner.id } }
        expect {
          put :update, params: params
          user.reload
        }.not_to change(user, :vita_partner_id)
      end

      it "does not persist supported_organization_ids to user" do
        new_vita_partner = create(:vita_partner)
        params = { id: user.id, user: { supported_organization_ids: [new_vita_partner.id] } }
        expect {
          put :update, params: params
          user.reload
        }.not_to change(user.supported_organizations, :count)

        expect(user.memberships).to include(have_attributes(vita_partner_id: new_vita_partner.id, role: "lead"))
      end

      it "can change primary vita partner membership" do
        new_vita_partner = create(:vita_partner)
        params = { id: user.id, user: { vita_partner_id: new_vita_partner.id } }
        put :update, params: params
        user.reload

        expect(user.memberships.length).to eq 1
        expect(user.memberships).to include(have_attributes(vita_partner_id: new_vita_partner.id, role: "member"))
      end


      it "can set primary vita partner membership" do
        new_vita_partner = create(:vita_partner)
        user = create :user, memberships: []
        params = { id: user.id, user: { vita_partner_id: new_vita_partner.id, supported_organization_ids: [] } }

        put :update, params: params

        user.reload
        expect(user.memberships.length).to eq 1
        expect(user.memberships).to include(have_attributes(vita_partner_id: new_vita_partner.id, role: "member"))
      end

      it "can set supported organization without vita_partner_id" do
        new_vita_partner = create(:vita_partner)
        user = create :user, memberships: []
        params = { id: user.id, user: { supported_organization_ids: [new_vita_partner.id] } }

        put :update, params: params

        user.reload
        expect(user.memberships.length).to eq 1
        expect(user.memberships).to include(have_attributes(vita_partner_id: new_vita_partner.id, role: "lead"))
      end

      it "can set supported organization with nil" do
        new_vita_partner = create(:vita_partner)
        user = create :user, memberships: []
        params = { id: user.id, user: {vita_partner_id: nil, supported_organization_ids: [new_vita_partner.id] } }

        put :update, params: params

        user.reload
        expect(user.memberships.length).to eq 1
        expect(user.memberships).to include(have_attributes(vita_partner_id: new_vita_partner.id, role: "lead"))
      end

      it "can set supported organization with empty vita_partner_id" do
        new_vita_partner = create(:vita_partner)
        user = create :user, memberships: []
        params = { id: user.id, user: { vita_partner_id: "", supported_organization_ids: [new_vita_partner.id] } }

        put :update, params: params

        user.reload
        expect(user.memberships.length).to eq 1
        expect(user.memberships).to include(have_attributes(vita_partner_id: new_vita_partner.id, role: "lead"))
      end

      it "can remove primary vita partner membership" do
        new_vita_partner = create(:vita_partner)
        user = create :user, memberships: [build(:membership, vita_partner: create(:vita_partner))]
        params = { id: user.id, user: { vita_partner_id: new_vita_partner.id } }

        put :update, params: params

        user.reload
        expect(user.memberships.length).to eq 1
        expect(user.memberships).to include(have_attributes(vita_partner_id: new_vita_partner.id, role: "member"))
      end

      context "when the user does not successfully update" do
        before do
          allow_any_instance_of(User).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
        end

        it "should rollback transaction and not destroy the existing memberships" do
          new_vita_partner = create(:vita_partner)
          user = create :user, memberships: [build(:membership, vita_partner: vita_partner)]
          params = { id: user.id, user: { vita_partner_id: new_vita_partner.id } }
          put :update, params: params

          user.reload
          expect(user.memberships.length).to eq 1
          expect(user.memberships).to include(have_attributes(vita_partner_id: vita_partner.id, role: "member"))
        end
      end
    end
  end
end
