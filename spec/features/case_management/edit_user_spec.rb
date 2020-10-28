require "rails_helper"

RSpec.describe "a user editing a user" do
  # TODO change all of these tests to redirect to show after save, then check the page for relevant info instead of the model
  context "as a beta tester" do
    let(:vita_partner) { create :vita_partner }
    let(:current_user) { create :beta_tester, vita_partner: vita_partner }
    let(:user) { create :beta_tester, vita_partner: vita_partner }
    before { login_as current_user }

    scenario "update only available fields" do
      visit edit_user_path(id: user.id)

      expect(page).to have_text user.name
      expect(find_field("user_vita_partner_id").value).to eq user.vita_partner.id.to_s

      uncheck "Beta tester?"

      click_on "Save"

      expect(user.reload.is_beta_tester).to eq false
    end

    context "as a admin" do
      let!(:vita_partner_1) { create :vita_partner, display_name: "Cabbage Patch Assistance (CPA)" }
      let!(:vita_partner_2) { create :vita_partner, display_name: "Brussels Proud" }

      before do
        current_user.update(is_admin: true)
      end

      scenario "update all fields" do
        visit edit_user_path(id: user.id)

        check "Admin"

        click_on "Select supported organizations"
        check "Cabbage Patch Assistance (CPA)"
        check "Brussels Proud"

        click_on "Save"

        user.reload
        expect(user.is_admin).to eq true
        expect(user.supported_organization_ids.sort).to eq [vita_partner_1.id, vita_partner_2.id]
      end
    end
  end
end
