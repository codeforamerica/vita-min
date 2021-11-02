require "rails_helper"

RSpec.feature "Logging in and out to the volunteer portal" do
  let!(:user) { create(:user, name: "German Geranium", email: "german@flowers.orange", password: "goodPassword") }

  scenario "logging in and out" do
    # go to password-based sign in page
    visit new_user_session_path

    within(".main-header") do
      expect(page).to have_link("The Hub", href: hub_assigned_clients_path)
    end

    expect(page).to have_text "Sign in"
    fill_in "Email", with: "german@flowers.orange"
    fill_in "Password", with: "goodPassword"
    click_on "Sign in"

    # Expect to be redirected to dashboard
    expect(page).to have_text "Welcome German Geranium"
    expect(page).to have_text "Assigned clients"

    click_on "Sign out"
    # Should be redirected to home page
    expect(page).to have_text "You've been successfully signed out."
    expect(page).to have_text "Free tax filing"
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
    fill_in "New password", with: "newPassword"
    fill_in "Confirm new password", with: "newPassword"
    click_on "Change my password"

    expect(user.reload.valid_password?("newPassword")).to eq(true)
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
end
