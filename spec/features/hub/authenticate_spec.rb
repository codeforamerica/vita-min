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

  scenario "non-admin user is forced to reset password" do
    user.assign_attributes(high_quality_password_as_of: nil, password: 'insecure')
    user.save(validate: false)

    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "insecure"
    click_on "Sign in"

    expect(page).to have_text("Please update your password.")

    fill_in "New password", with: "UseAStronger!Password2023"
    fill_in "Confirm new password", with: "UseAStronger!Password2023"
    click_on "Update"

    expect(page).to have_text(I18n.t('hub.assigned_clients.index.title'))
  end

  scenario "strong passwords are only enforced on the next sign-in" do
    login_as user
    visit hub_clients_path
    expect(page).to have_link(I18n.t("general.add_client"))

    user.assign_attributes(should_enforce_strong_password: false)
    user.assign_attributes(password: "password123")
    user.save(validate: false)

    visit hub_clients_path
    # expect(page).to have_text("Forgot your password?")
    expect(page).to have_link(I18n.t("general.add_client"))
  end
end
