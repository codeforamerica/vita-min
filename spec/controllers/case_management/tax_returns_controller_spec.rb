require 'rails_helper'

RSpec.describe CaseManagement::TaxReturnsController, type: :controller do
  let(:vita_partner) { create :vita_partner }
  let(:client) { create :client, vita_partner: vita_partner, intake: create(:intake, preferred_name: "Lucille") }
  let(:tax_return) { create :tax_return, client: client, year: 2018 }

  describe "#edit" do
    let(:params) {
      {
        client_id: client.id,
        id: tax_return.id,
      }
    }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    # with a tax_return_status param that has a template (from client profile link)
      # it prepopulates the form with certain values
        # it uses the correct template
        # it fills out the template with the right values
    # with a certain locale
      # it pre-selects the langauge based on locale
      # when the itnerview preference doesn't match the locale
        # it shows a warning
    # when the client has certain contact preferences
      # it shows a warning

    context "as an authenticated user" do
      render_views
      let(:user) { create :user, vita_partner: vita_partner }
      let!(:other_user) { create :user, vita_partner: vita_partner }
      let!(:outside_org_user) { create :user }
      before { sign_in user }

      it "offers me a list of other users in my organization for assignment" do
        get :edit, params: params

        expect(response).to be_ok
        expect(assigns(:assignable_users)).to include(other_user)
        expect(assigns(:assignable_users)).not_to include(outside_org_user)
        assigned_user_dropdown = Nokogiri::HTML.parse(response.body).at_css("select#tax_return_assigned_user_id")

        # does it show a blank option?
        first_option = assigned_user_dropdown.at_css("option:first-child")
        expect(first_option["value"]).to be_blank
        expect(first_option.text).to be_blank

        expect(assigned_user_dropdown.at_css("option[value=\"#{other_user.id}\"]")).to be_present
        expect(assigned_user_dropdown.at_css("option[value=\"#{user.id}\"]")).to be_present

        expect(assigned_user_dropdown.at_css("option[value=\"#{outside_org_user.id}\"]")).not_to be_present
      end
    end

    context "as an admin user" do
      let(:admin) { create :admin_user, vita_partner: create(:vita_partner) }
      let!(:other_user) { create :user, vita_partner: vita_partner }
      let!(:outside_org_user) { create :user, vita_partner: admin.vita_partner }
      before { sign_in admin }

      it "offers a list of users based on client's partner, not admin's org" do
        get :edit, params: params
        expect(assigns(:assignable_users)).to eq([other_user])
      end
    end
  end

  describe "#update" do
    let(:assigned_user) { create :user, name: "Buster" }
    let(:params) {
      {
        client_id: client.id,
        id: tax_return.id,
        tax_return: { assigned_user_id: assigned_user.id }
      }
    }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "as an authenticated user" do
      let(:user) { create :user, vita_partner: vita_partner }
      before { sign_in user }

      it "assigns the user to the tax return" do
        put :update, params: params

        tax_return.reload
        expect(tax_return.assigned_user).to eq assigned_user
        expect(response).to redirect_to case_management_clients_path
        expect(flash[:notice]).to eq "Assigned Lucille's 2018 tax return to Buster"
      end

      # when there is content in the note field
        # it saves a note
      # when there is content in the email field
        # it enqueues a email
      # when there is content in the text message field
        # it enqueues a text message 

      context "unassigning the tax return" do
        let(:params) {
          {
              client_id: client.id,
              id: tax_return.id,
              tax_return: { assigned_user_id: "" }
          }
        }

        it "removes the assigned user from the tax return" do
          put :update, params: params

          tax_return.reload
          expect(tax_return.assigned_user).not_to be_present
          expect(flash[:notice]).to eq "Assigned Lucille's 2018 tax return to no one"
        end
      end
    end
  end

  describe "#update_status" do
    let(:user) { create :user, vita_partner: (create :vita_partner) }
    let(:tax_return) { create :tax_return, status: "intake_in_progress", client: (create :client, vita_partner: user.vita_partner) }
    let(:params) { { tax_return: { status: "review_complete_signature_requested" }, id: tax_return.id, client_id: tax_return.client } }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update_status

    context "as an authenticated user" do
      before { sign_in user }

      it "creates a system note" do
        expect(SystemNote).to receive(:create_status_change_note).with(user, tax_return)
        post :update_status, params: params
      end

      it "redirects to the messages tab" do
        post :update_status, params: params
        expect(response).to redirect_to case_management_client_messages_path(client_id: tax_return.client.id)
      end

      it "updates the status on the indicated tax return" do
        post :update_status, params: params
        tax_return.reload

        expect(tax_return.status).to eq("review_complete_signature_requested")
      end
    end
  end

  describe "#edit_status" do
    let(:user) { create :user_with_org }
    let(:tax_return) { create :tax_return, client: create(:client, vita_partner: user.vita_partner) }
    let(:params) { { id: tax_return.id, client_id: tax_return.client } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit_status

    context "as an authenticated user" do
      before { sign_in user }

      it "returns an ok response" do
        post :edit_status, params: params
        expect(response).to be_ok
      end

      it "finds the tax return" do
        get :edit_status, params: params

        expect(assigns(:tax_return)).to eq(tax_return)
      end
    end
  end
end