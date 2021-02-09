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

        click_on "Return to Profile"
        expect(page).to have_current_path(hub_user_profile_path)

        click_on "Return to Dashboard"
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

      scenario "resending invitations" do
        visit edit_hub_user_path(id: user_to_edit.id)

        click_on "Resend invitation email"

        within(".flash--notice") do
          expect(page).to have_text "Invitation re-sent to #{user_to_edit.email}"
        end

        mail = ActionMailer::Base.deliveries.last
        html_body = mail.body.parts[1].decoded
        accept_invite_url = Nokogiri::HTML.parse(html_body).at_css("a")["href"]
        expect(mail.subject).to eq "You've been invited to GetYourRefund"
        expect(accept_invite_url).to be_present
        expect(mail.body.encoded).to have_text "Hello,"
        expect(mail.body.encoded).to have_text "#{current_user.name} (#{current_user.email}) has invited #{user_to_edit.name} to create an account on GetYourRefund"
        expect(mail.body.encoded).to have_text "If you don't want to accept the invitation, please ignore this email."
      end
    end
  end
end
