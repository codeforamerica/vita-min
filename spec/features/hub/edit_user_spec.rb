require "rails_helper"

RSpec.describe "a user editing a user" do
  context "as an authenticated user" do
    context "as an admin" do
      let!(:colorado_org) { create :vita_partner, name: "Colorado" }
      let!(:denver_org) { create :vita_partner, parent_organization: colorado_org, name: "Denver" }
      let!(:california_org) { create :vita_partner, name: "California" }
      let!(:san_fran_org) { create :vita_partner, parent_organization: california_org, name: "San Francisco" }
      let(:current_user) { create :admin_user, vita_partner: colorado_org }
      let(:user_to_edit) { create :user, vita_partner: colorado_org }
      before { login_as current_user }

      scenario "update all fields" do
        visit edit_hub_user_path(id: user_to_edit.id)
        expect(page).to have_text user_to_edit.name

        check "Admin"
        check "Client support"

        click_on "Select supported organizations"
        check "Colorado"
        check "Denver"

        click_on "Save"
        expect(page).to have_text "Changes saved"

        expect(page).to have_field("user_supported_organization_ids_#{colorado_org.id}", checked: true)
        expect(page).to have_field("user_supported_organization_ids_#{denver_org.id}", checked: true)
        expect(page).to have_field("user_supported_organization_ids_#{california_org.id}", checked: false)
        expect(page).to have_field("user_supported_organization_ids_#{san_fran_org.id}", checked: false)
        expect(page).to have_field("user_is_admin", checked: true)
        expect(page).to have_field("user_is_client_support", checked: true)
      end
    end
  end
end
