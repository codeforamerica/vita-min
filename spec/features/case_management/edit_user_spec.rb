require "rails_helper"

RSpec.describe "a user editing a user" do
  context "as a beta tester" do
    context "as a non-admin" do
      let(:vita_partner) { create :vita_partner }
      let(:current_user) { create :beta_tester, vita_partner: vita_partner }
      let(:user) { create :beta_tester, vita_partner: vita_partner }
      before { login_as current_user }

      scenario "update another user's beta tester status" do
        visit edit_user_path(id: user.id)

        expect(page).to have_text user.name
        expect(find_field("user_vita_partner_id").value).to eq user.vita_partner.id.to_s

        uncheck "Beta tester?"

        click_on "Save"

        expect(page).to have_text "Changes saved"
        expect(page).to have_field("user_is_beta_tester", checked: false)
      end
    end

    context "as an admin" do
      let(:current_user) { create :admin_user, vita_partner: create(:vita_partner) }
      let(:user) { create :beta_tester, vita_partner: current_user.vita_partner }

      let!(:vita_partner_1) { create :vita_partner, display_name: "Cabbage Patch Assistance (CPA)" }
      let!(:vita_partner_2) { create :vita_partner, display_name: "Brussels Proud" }
      let!(:vita_partner_3) { create :vita_partner, display_name: "Orange Among Us" }

      before do
        login_as(current_user)
      end

      scenario "update all fields" do
        visit edit_user_path(id: user.id)

        check "Admin"

        click_on "Select supported organizations"
        check "Cabbage Patch Assistance (CPA)"
        check "Brussels Proud"

        click_on "Save"
        expect(page).to have_text "Changes saved"

        expect(page).to have_field("user_supported_organization_ids_#{vita_partner_1.id}", checked: true)
        expect(page).to have_field("user_supported_organization_ids_#{vita_partner_2.id}", checked: true)
        expect(page).to have_field("user_supported_organization_ids_#{vita_partner_3.id}", checked: false)
        expect(page).to have_field("user_is_admin", checked: true)
      end
    end
  end
end
