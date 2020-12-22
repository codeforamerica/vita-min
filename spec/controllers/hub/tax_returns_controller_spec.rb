require "rails_helper"

RSpec.describe Hub::TaxReturnsController, type: :controller do
  let(:user) { create :organization_lead_user }
  let(:client) { create :client, intake: create(:intake, preferred_name: "Lucille", vita_partner: user.role.organization), vita_partner: user.role.organization }
  let(:tax_return) { create :tax_return, client: client, year: 2018 }

  describe "#edit" do
    let(:params) {
      {
        client_id: client.id,
        id: tax_return.id,
      }
    }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an org lead" do
      render_views
      let!(:other_user) { create :organization_lead_user, organization: user.role.organization }
      let!(:outside_org_user) { create :organization_lead_user }

      before { sign_in user }

      it "offers me a list of other users in the client's organization for assignment" do
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
      before do
        sign_in user
        allow(SystemNote).to receive(:create_assignment_change_note)
      end

      it "assigns the user to the tax return" do
        put :update, params: params

        tax_return.reload
        expect(tax_return.assigned_user).to eq assigned_user
        expect(response).to redirect_to hub_clients_path
        expect(flash[:notice]).to eq "Assigned Lucille's 2018 tax return to Buster"
        expect(SystemNote).to have_received(:create_assignment_change_note).with(user, tax_return)
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
