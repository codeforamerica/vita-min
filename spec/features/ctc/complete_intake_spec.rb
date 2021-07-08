require "rails_helper"

RSpec.feature "CTC Intake", :js, active_job: true  do
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  scenario "new client entering ctc intake flow" do
    visit "/en/questions/overview"
    expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
    expect(page).to have_selector("h1", text: "Let's get started!")
    click_on "Continue"

    expect(page).to have_selector(".toolbar", text: "GetCTC")
    expect(page).to have_selector("h1", text: "First, what's your name?")
    expect(page).to have_selector("p", text: "Welcome, we're excited to help you. We need some basic information to get started. We’ll start by asking what you like being called.")
    fill_in "Preferred first name", with: "Gary"
    click_on "Continue"

    intake = Intake.last
    expect(intake.preferred_name).to eq "Gary"
    expect(intake.timezone).not_to be_blank
    expect(intake.client).not_to be_blank

    expect(page).to have_selector("h1", text: "What is the best way to reach you?")
    click_on "Send me texts"
    expect(page).to have_selector("h1", text: "Please share your phone number.")
    fill_in "Cell phone number", with: "8324658840"
    fill_in "Confirm cell phone number", with: "8324658840"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Please share your phone number.")
    expect(page).to have_selector(".text--error", text: "Please provide a phone number that can receive texts")
    click_on "provide an email address instead"

    expect(page).to have_selector("h1", text: "Please share your e-mail address.")
    fill_in "E-mail address", with: "mango@example.com"
    fill_in "Confirm e-mail address", with: "mango@example.com"
    click_on "Continue"

    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    expect(mail.html_part.body.to_s).to have_text("Your 6-digit GetCTC verification code is: ")
    code = mail.html_part.body.to_s.match(/Your 6-digit GetCTC verification code is: (\d+)/)[1]

    expect(page).to have_selector("p", text: "A message with your code has been sent to: mango@example.com")
    fill_in "Enter 6 digit code", with: "000001"
    click_on "Continue"
    expect(page).to have_content("Incorrect verification code.")

    fill_in "Enter 6 digit code", with: code
    click_on "Continue"

    expect(page).to have_selector("h1", text: "In order to file, we’ll need some additional information.")
    fill_in "Legal first name", with: "Gary"
    fill_in "Middle initial", with: "H"
    fill_in "Legal last name", with: "Mango"
    fill_in "ctc_consent_form_primary_birth_date_month", with: "08"
    fill_in "ctc_consent_form_primary_birth_date_day", with: "24"
    fill_in "ctc_consent_form_primary_birth_date_year", with: "1996"
    fill_in "Social Security Number (SSN) or Individual Taxpayer ID Number (ITIN)", with: "111-22-8888"
    fill_in "Confirm SSN or ITIN", with: "111-22-8888"
    fill_in "Phone number", with: "831-234-5678"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Placeholder -- Coming soon")

    # Skip to bank account questions until we can arrive here naturally.
    visit "en/questions/refund-payment"
    expect(page).to have_selector("h1", text: "If you are supposed to get money, how would you like to receive it?")
    choose "Direct deposit (fastest)"
    click_on "Continue"
    expect(page).to have_selector("h1", text: "Great, please provide your bank details below!")
    fill_in "Bank name", with: "Bank of Two Melons"
    choose "Checking"
    check "My name is on this bank account"
    click_on "Continue"
  end
end