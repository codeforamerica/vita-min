require "rails_helper"

RSpec.feature "Inviting client success" do
  context "As an admin user" do
    let(:user) { create :admin_user }
    before do
      login_as user
    end

    scenario "Inviting, re-sending invites, and accepting invites" do
      visit hub_tools_path
      click_on "Invitations"

      # Invitations page
      page_change_check("Invitations")
      select "Client Success", from: "What type of user do you want to invite?"
      click_on "Continue"

      # new invitation page
      page_change_check("Send a new invitation")
      fill_in "What is their name?", with: "Chard Swiss"
      fill_in "What is their email?", with: "chard@clientsuccess.org"
      click_on "Send invitation email"

      # back on the invitations page
      within(".flash--notice") do
        page_change_check("We sent an email invitation to chard@clientsuccess.org")
      end
      within(".invitations") do
        expect(page).to have_text "Chard Swiss"
        expect(page).to have_text "chard@clientsuccess.org"
        expect(page).to have_text "Client Success"
      end
      invited_user = User.where(invited_by: user).last
      expect(invited_user).to be_present

      # resend invitation
      within("#invitation-#{invited_user.id}") do
        click_on "Resend invitation email"
      end

      within(".flash--notice") do
        page_change_check("Invitation re-sent to chard@clientsuccess.org")
      end
      invited_user = User.where(invited_by: user).last
      expect(invited_user.invitation_token).to be_present

      logout
      sleep 0.1

      # New invitation recipient signing up!
      mail = ActionMailer::Base.deliveries.last
      html_body = mail.body.parts[1].decoded
      accept_invite_url = Nokogiri::HTML.parse(html_body).at_css("a")["href"]
      expect(mail.subject).to eq "You've been invited to GetYourRefund"
      expect(accept_invite_url).to be_present
      expect(mail.body.encoded).to have_text "Hello,"
      expect(mail.body.encoded).to have_text "#{user.name} (#{user.email}) has invited #{invited_user.name} to create an account on GetYourRefund"
      expect(mail.body.encoded).to have_text "If you don't want to accept the invitation, please ignore this email."

      # Sign up page
      visit accept_invite_url
      page_change_check("Thank you for signing up to help!")
      expect(page).to have_text "chard@clientsuccess.org"
      expect(find_field("What is your name?").value).to eq "Chard Swiss"
      fill_in "Please choose a strong password", with: "c0v3rt-c4ul1fl0wer"
      fill_in "Enter your new password again", with: "c0v3rt-c4ul1fl0wer"
      click_on "Get started"

      page_change_check("You're all set and ready to go! You've joined an amazing team!")
      expect(page).to have_text "Chard Swiss"
      expect(page).to have_text "Client Success"
    end
  end
end
