require "rails_helper"

RSpec.describe "a user editing a user" do
  context "as an authenticated user" do
    context "as an admin" do
      let(:current_user) { create :admin_user }
      let(:user_to_edit) { create :user }
      before { login_as current_user }

      scenario "navigation" do
        visit edit_hub_user_path(id: user_to_edit.id)
        click_on "Cancel"
        expect(page).to have_current_path(hub_users_path)

        click_on "Return to profile"
        expect(page).to have_current_path(hub_user_profile_path)

        click_on "Return to dashboard"
        expect(page).to have_current_path(hub_root_path)
      end

      scenario "update all fields" do
        visit edit_hub_user_path(id: user_to_edit.id)
        expect(page).to have_text user_to_edit.name

        check "Admin"

        click_on "Save"

        expect(page).to have_text "Changes saved"

        expect(page).to have_field("user_is_admin", checked: true)
      end
    end
  end
end
