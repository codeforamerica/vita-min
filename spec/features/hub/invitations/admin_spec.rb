require "rails_helper"

RSpec.feature "Inviting admin users" do
  context "As an admin user" do
    let(:user) { create :admin_user }
    let(:oauth_uid) { '12345' }

    before do
      login_as user
    end

    around do |example|
      OmniAuth.config.test_mode = true
      OmniAuth.config.add_mock(
        :google_oauth2,
        { uid: oauth_uid, info: { email: "aileen@codeforamerica.org" }, extra: { id_info: { hd: "codeforamerica.org" } } }
      )
      example.run
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:google_oauth2] = nil
    end

    scenario "Inviting, re-sending invites, and accepting invites" do
      visit hub_tools_path
      click_on "Invitations"

      # Invitations page
      expect(page).to have_selector "h1", text: "Invitations"
      select "Admin", from: "What type of user do you want to invite?"
      click_on "Continue"

      # new invitation page
      expect(page).to have_text "Send a new invitation"
      fill_in "What is their name?", with: "Aileen Artichoke"
      fill_in "What is their email?", with: "aileen@codeforamerica.org"
      click_on "Send invitation email"

      # back on the invitations page
      within(".flash--notice") do
        expect(page).to have_text "We sent an email invitation to aileen@codeforamerica.org"
      end
      within(".invitations") do
        expect(page).to have_text "Aileen Artichoke"
        expect(page).to have_text "aileen@codeforamerica.org"
        expect(page).to have_text "Admin"
      end
      invited_user = User.where(invited_by: user).last
      expect(invited_user).to be_present

      # resend invitation
      within("#invitation-#{invited_user.id}") do
        click_on "Resend invitation"
      end
      within(".flash--notice") do
        expect(page).to have_text "Invitation re-sent to aileen@codeforamerica.org"
      end
      invited_user = User.where(invited_by: user).last
      expect(invited_user.invitation_sent_at).to be_within(2.seconds).of(Time.now)

      logout

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
      expect(page).to have_text "Thank you for signing up to help!"
      expect(page).to have_text "aileen@codeforamerica.org"
      expect(find_field("What is your name?").value).to eq "Aileen Artichoke"
      fill_in "What is your name?", with: ""
      click_on "Get started"
      expect(page).to have_text "Thank you for signing up to help!"
      fill_in "What is your name?", with: "Yaileen Yartichoke"
      click_on "Get started"

      expect(page).to have_text I18n.t("controllers.users.sessions_controller.must_use_admin_sign_in")
      expect(page).to have_text I18n.t('devise.invitations.updated')

      click_on I18n.t("general.sign_in_admin")

      expect(page).to have_text "Yaileen Yartichoke"
      expect(page).to have_text "Admin"
      expect(User.find_by(email: "aileen@codeforamerica.org").external_uid).to eq(oauth_uid)
    end

    it "shows errors if the required data was not provided" do
      visit hub_tools_path
      click_on "Invitations"

      # Invitations page
      expect(page).to have_selector "h1", text: "Invitations"
      select "Admin", from: "What type of user do you want to invite?"
      click_on "Continue"

      # new invitation page
      expect(page).to have_text "Send a new invitation"
      click_on "Send invitation email"

      expect(page).to have_text(I18n.t('errors.messages.blank'))
      expect(page).to have_select('Which role?', selected: 'AdminRole', disabled: true)
    end
  end
end
