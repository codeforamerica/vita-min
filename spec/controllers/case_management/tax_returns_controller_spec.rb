require 'rails_helper'

RSpec.describe CaseManagement::TaxReturnsController, type: :controller do
  let(:vita_partner) { create :vita_partner }
  let(:client) { create :client, preferred_name: "Lucille", vita_partner: vita_partner }
  let(:tax_return) { create :tax_return, client: client, year: 2018 }

  describe "#edit" do
    let(:params) {
      {
        client_id: client.id,
        id: tax_return.id,
      }
    }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit
    it_behaves_like :a_get_action_for_beta_testers_only, action: :edit

    context "as an authenticated beta tester" do
      render_views
      let(:user) { create :beta_tester, vita_partner: vita_partner }
      let!(:other_user) { create :user, vita_partner: vita_partner }
      let!(:outside_org_user) { create :user }
      before { sign_in user }

      it "offers me a list of other users in my organization for assignment" do
        get :edit, params: params

        expect(response).to be_ok
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
    it_behaves_like :a_post_action_for_beta_testers_only, action: :update

    context "as an authenticated beta tester" do
      let(:user) { create :beta_tester, vita_partner: vita_partner }
      before { sign_in user }

      it "assigns the user to the tax return" do
        put :update, params: params

        tax_return.reload
        expect(tax_return.assigned_user).to eq assigned_user
        expect(response).to redirect_to case_management_clients_path
        expect(flash[:notice]).to eq "Assigned Lucille's 2018 tax return to Buster"
      end

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
end

