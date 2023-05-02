require "rails_helper"

RSpec.feature "Logging in and out to the volunteer portal" do
  let!(:user) { create(:user, name: "German Geranium", email: "german@flowers.orange", password: "someotherword88!!") }

  scenario "logging in and out" do
    allow(MixpanelService).to receive(:send_event)
    # go to password-based sign in page
    visit new_user_session_path

    expect(page).to have_text "Sign in"
    fill_in "Email", with: "german@flowers.orange"
    fill_in "Password", with: "someotherword88!!"
    click_on "Sign in"

    # Expect to be redirected to dashboard
    expect(page).to have_text "My Clients"

    click_on "Sign out"
    # Should be redirected to home page
    expect(page).to have_text "You've been successfully signed out."
    expect(page).to have_text "Free tax filing"
    expect(MixpanelService).to have_received(:send_event).with(a_hash_including(event_name: 'hub_user_login'))
  end

  scenario "getting locked out due to using the wrong password a lot" do
    # go to password-based sign in page
    visit new_user_session_path

    user.update(failed_attempts: 4)
    expect do
      expect(page).to have_text "Sign in"
      fill_in "Email", with: "german@flowers.orange"
      fill_in "Password", with: "wrongPassword"
      click_on "Sign in"
      expect(page).to have_text "Incorrect email or password. After 5 login attempts, accounts are locked."
    end.to change { user.reload.failed_attempts }.by(1).and change { user.reload.locked_at.present? }.from(false).to(true)
  end

  scenario "resetting password" do
    visit new_user_session_path
    fill_in "Email", with: "german@flowers.orange"
    fill_in "Password", with: "notQuiteGoodPassword"
    click_on "Sign in"
    expect(page).to have_text "Incorrect email or password."
    click_on "Forgot your password?"

    # Send email to get reset link
    expect(page).to have_text "Forgot your password?"
    expect(find_field("Email").value).to eq "german@flowers.orange"
    expect do
      click_on "Send me reset password instructions"
    end.to change(ActionMailer::Base.deliveries, :count).by 1
    expect(page).to have_text "If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes."

    email = ActionMailer::Base.deliveries.last
    # Expect from address to equal the configured address for the testing environment
    expect(email.from).to eq(['no-reply@test.localhost'])
    # Expect subject to
    expect(email.subject).to eq("Reset password instructions")

    html_body = email.body.encoded
    reset_password_link = Nokogiri::HTML.parse(html_body).at_css("a")["href"]
    visit(reset_password_link)
    expect(page).to have_text "Change your password"
    fill_in "New password", with: "notQuiteGoodPa55word88!!"
    fill_in "Confirm new password", with: "notQuiteGoodPa55word88!!"
    click_on "Change my password"

    expect(user.reload.valid_password?("notQuiteGoodPa55word88!!")).to eq(true)
  end

  scenario "resetting password with old/outdated/invalid link" do
    visit edit_user_password_path(reset_password_token: "invalidResetToken")
    expect(page).to have_text "Change your password"
    fill_in "New password", with: "newPassword"
    fill_in "Confirm new password", with: "newPassword"
    expect {
      click_on "Change my password"
    }.not_to change { user.reload.updated_at }
    # Show our specific custom error message
    expect(page).to have_text("Oops, we're sorry, but something went wrong")
  end

  context "with a non-admin user whose password is low quality" do
    before do
      user.assign_attributes(high_quality_password_as_of: nil, password: 'insecure', should_enforce_strong_password: false)
      user.save(validate: false)
    end

    it "makes them set a new password" do
      visit new_user_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: "insecure"
      click_on "Sign in"

      expect(user.reload.should_enforce_strong_password).to eq(true)

      expect(page).to have_text("Please update your password")

      fill_in "New password", with: "UseAStronger!Password2023"
      fill_in "Confirm new password", with: "UseAStronger!Password2023"
      click_on "Update"

      expect(page).to have_text(I18n.t('hub.assigned_clients.index.title'))
    end

    context "when the user is already signed in" do
      before do
        user.assign_attributes(high_quality_password_as_of: nil, password: 'insecure', should_enforce_strong_password: false)
        user.save(validate: false)
      end

      scenario "it waits until the next sign-in to trigger strong password flow" do
        login_as user
        expect(user.should_enforce_strong_password).to eq(false)
        visit hub_clients_path
        expect(page).to have_link(I18n.t("general.add_client"))
      end
    end
  end

  context "when signing in with Google" do
    before do
      create(:admin_user, email: "example@codeforamerica.org")
      OmniAuth.config.test_mode = true
      OmniAuth.config.add_mock(
        :google_oauth2,
        { uid: '12345', info: { email: "example@codeforamerica.org" }, extra: { id_info: { hd: "codeforamerica.org" } } }
      )
    end

    after do
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:google_oauth2] = nil
    end

    it "signs the user in", js: true do
      visit new_user_session_path
      click_on I18n.t("general.sign_in_admin")
      expect(page).to have_text(I18n.t('devise.omniauth_callbacks.success', kind: "Google"))
    end
  end
end
