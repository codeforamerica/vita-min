require "rails_helper"

RSpec.feature "CTC Intake", :js, :flow_explorer_screenshot, active_job: true do
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  scenario "new client entering ctc intake flow" do
    # =========== BASIC INFO ===========
    visit "/en/questions/overview"
    expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
    expect(page).to have_selector("h1", text: "Let's get started!")
    click_on "Continue"

    expect(page).to have_selector(".toolbar", text: "GetCTC")
    expect(page).to have_selector("h1", text: "Did you earn any income in 2020?")
    click_on "No"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "In order to file, we’ll need some additional information.")
    fill_in "Legal first name", with: "Gary"
    fill_in "Middle initial", with: "H"
    fill_in "Legal last name", with: "Mango"
    fill_in "ctc_consent_form_primary_birth_date_month", with: "08"
    fill_in "ctc_consent_form_primary_birth_date_day", with: "24"
    fill_in "ctc_consent_form_primary_birth_date_year", with: "1996"
    fill_in "SSN or ITIN", with: "111-22-8888"
    fill_in "Confirm SSN or ITIN", with: "111-22-8888"
    fill_in "Phone number", with: "831-234-5678"
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

    expect(page).to have_selector("p", text: "A message with your code has been sent to: mango@example.com")

    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    expect(mail.html_part.body.to_s).to have_text("Your 6-digit GetCTC verification code is: ")
    code = mail.html_part.body.to_s.match(/Your 6-digit GetCTC verification code is: (\d+)/)[1]

    fill_in "Enter 6 digit code", with: "000001"
    click_on "Continue"
    expect(page).to have_content("Incorrect verification code.")

    fill_in "Enter 6 digit code", with: code
    click_on "Continue"

    # =========== LIFE SITUATIONS ===========
    expect(page).to have_selector("h1", text: "Did you file a 2020 tax return this year?")
    click_on "No"
    expect(page).to have_selector("h1", text: "Did you either file a 2019 tax return or receive any stimulus payments?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "Let's check one more thing.")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Where was your main home for 2020?")
    check "Any of the 50 states or the District of Columbia"
    check "Foreign address"
    click_on "Continue"
    expect(page).to have_selector("h1", text:  "Unfortunately, you are not eligible to use GetCTC. But we can still help!")
    click_on "Go back"
    expect(page).to have_selector("h1", text: "Where was your main home for 2020?")
    check "Any of the 50 states or the District of Columbia"
    check "U.S. military facility"
    click_on "Continue"
    expect(page).to have_selector("h1", text: "Select any situations that were true for you in 2020")
    check "No one can claim me as a dependent"
    click_on "Continue"

    # =========== FILING STATUS ===========
    expect(page).to have_selector("h1", text: "How will you be filing your tax return?")
    choose "Married filing jointly"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Tell us about your spouse")
    fill_in "Spouse's legal first name", with: "Peter"
    fill_in "Middle initial", with: "P"
    fill_in "Spouse's legal last name", with: "Pepper"
    fill_in "ctc_spouse_info_form[spouse_birth_date_month]", with: "01"
    fill_in "ctc_spouse_info_form[spouse_birth_date_day]", with: "11"
    fill_in "ctc_spouse_info_form[spouse_birth_date_year]", with: "1995"
    select "Social Security Number (SSN)"
    fill_in "Spouse's SSN or ITIN", with: "222-33-4444"
    fill_in "Confirm spouse's SSN or ITIN", with: "222-33-4444"
    click_on "Save this person"
    expect(page).not_to have_text("Remove this person")

    expect(page).to have_text("Let's confirm your spouse's information.")
    expect(page).to have_text("Peter Pepper")
    expect(page).to have_text("Date of birth: 1/11/1995")
    expect(page).to have_text("SSN: XXX-XX-4444")
    click_on "edit"

    expect(page).to have_selector("h1", text: "Tell us about your spouse")
    click_on "Remove this person"

    expect(page).to have_selector("h1", text: "You're about to remove Peter Pepper.")
    click_on "Nevermind, let's save them"

    expect(page).to have_selector("h1", text: "Let's confirm your spouse's information.")
    click_on "Continue"

    # =========== DEPENDENTS ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.had_dependents.title'))
    # For some reason the presence of the tall "What relationships?" reveal blocks clicks to the yes/no,
    # even though the contents of the reveal should be hidden. What a mystery!
    page.execute_script("document.querySelector('.reveal').remove()")
    click_on "No"

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.no_dependents.title'))
    click_on "Go back"
    page.execute_script("document.querySelector('.reveal').remove()")
    click_on "Yes"

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.info.title'))
    fill_in I18n.t('views.ctc.questions.dependents.info.first_name'), with: "Jessie"
    fill_in I18n.t('views.ctc.questions.dependents.info.middle_initial'), with: "M"
    fill_in I18n.t('views.ctc.questions.dependents.info.last_name'), with: "Pepper"
    fill_in "ctc_dependents_info_form[birth_date_month]", with: "01"
    fill_in "ctc_dependents_info_form[birth_date_day]", with: "11"
    fill_in "ctc_dependents_info_form[birth_date_year]", with: "1995"
    select I18n.t('general.dependent_relationships.00_daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
    check I18n.t('views.ctc.questions.dependents.info.full_time_student')
    click_on "Continue"

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.tin.title', name: 'Jessie'))
    select "Social Security Number (SSN)"
    fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin', name: "Jessie"), with: "222-33-4445"
    fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin_confirmation', name: "Jessie"), with: "222-33-4445"
    click_on "Continue"

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.confirm_dependents.title'))
    expect(page).to have_content("Jessie")

    # Back up to prove that the 'go back' button brings us back to the dependent we were editing
    click_on "Go back"
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.tin.title', name: 'Jessie'))
    click_on "Continue"
    click_on I18n.t('views.ctc.questions.dependents.confirm_dependents.done_adding')

    # =========== RECOVERY REBATE CREDIT ===========
    expect(page).to have_selector("h1", text: "Based on your info, we believe you should have received this much in stimulus payments.")
    click_on "No, I didn’t receive this amount."
    expect(page).to have_selector("h1", text: "Did you receive any of the first stimulus payment?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "Enter the total amount you received for your first stimulus payment.")
    fill_in "Economic Impact Payment 1", with: "1200"
    click_on "Continue"
    expect(page).to have_selector("h1", text: "Did you receive any of the second stimulus payment?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "Enter the total amount you received for your second stimulus payment.")
    fill_in "Economic Impact Payment 2", with: "2100"
    click_on "Continue"
    # This part is temporary, and will need adjustment when we get RCC calculations working
    expect(page).to have_selector("h1", text: "Based on your info, it looks like you’ve received your full stimulus payments.")
    expect(page).to have_text("EIP 1: $1,200")
    expect(page).to have_text("EIP 2: $2,100")
    click_on "Continue"

    # =========== BANK AND MAILING INFO ===========
    expect(page).to have_selector("h1", text: "If you are supposed to get money, how would you like to receive it?")
    choose "Direct deposit (fastest)"
    click_on "Continue"
    expect(page).to have_selector("h1", text: "Great, please provide your bank details below!")
    fill_in "Bank name", with: "Bank of Two Melons"
    choose "Checking"
    check "My name is on this bank account"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Please provide your bank's routing number")
    fill_in "Routing number", with: "12345678"
    fill_in "Confirm routing number", with: "12345678"
    click_on "Continue"
    expect(page).to have_selector(".text--error", text: "is the wrong length (should be 9 characters)")
    fill_in "Routing number", with: "123456789"
    fill_in "Confirm routing number", with: "123456789"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Please provide your account number")
    fill_in "Account number", with: "123456789"
    fill_in "Confirm account number", with: "123456789"
    click_on "Continue"
    expect(page).to have_selector("h1", text: "Great! Check to make sure your bank information is correct.")
    expect(page).to have_selector("h2", text: "Your bank information")
    expect(page).to have_selector("li", text: "Bank of Two Melons")
    expect(page).to have_selector("li", text: "Type: Checking")
    expect(page).to have_selector("li", text: "Routing number: 123456789")
    expect(page).to have_selector("li", text: "Account number: ●●●●●6789")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Great, please provide your mailing address below.")
    fill_in "Street address or P.O. box", with: "26 William Street"
    fill_in "Apartment number (optional)", with: "Apt 1234"
    fill_in "City", with: "Bel Air"
    select "California", from: "State"
    fill_in "ZIP code", with: 90001
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Great! Please confirm your mailing address.")
    expect(page).to have_selector("h2", text: "Your mailing address")
    expect(page).to have_selector("div", text: "26 William Street")
    expect(page).to have_selector("div", text: "Apt 1234")
    expect(page).to have_selector("div", text: "Bel Air, CA 90001")
    click_on "Continue"

    # =========== REVIEW ===========

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.ip_pin.title'))
    check "Gary Mango"
    check "Jessie Pepper"
    click_on "Continue"

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.ip_pin_entry.title'))
    fill_in I18n.t('views.ctc.questions.ip_pin_entry.label', name: "Gary Mango"), with: "123456"
    fill_in I18n.t('views.ctc.questions.ip_pin_entry.label', name: "Jessie Pepper"), with: "123458"
    click_on "Continue"

    intake.reload
    expect(intake.primary_ip_pin).to eq "123456"
    expect(intake.dependents.last.ip_pin).to eq "123458"
    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_information.title"))

    expect(page).to have_selector("h2", text: I18n.t("views.ctc.questions.confirm_information.your_information"))
    expect(page).to have_selector("div", text: "Gary Mango")
    expect(page).to have_selector("div", text: "Date of birth: 8/24/1996")
    expect(page).to have_selector("div", text: "Email: mango@example.com")
    expect(page).to have_selector("div", text: "Phone: (831) 234-5678")
    expect(page).to have_selector("div", text: "SSN: XXX-XX-8888")

    expect(page).to have_selector("h2", text: "Your mailing address")
    expect(page).to have_selector("div", text: "26 William Street")
    expect(page).to have_selector("div", text: "Apt 1234")
    expect(page).to have_selector("div", text: "Bel Air, CA 90001")

    expect(intake.filing_joint?).to eq true
    expect(page).to have_selector("h2", text: I18n.t("views.ctc.questions.spouse_review.your_spouse"))
    expect(page).to have_selector("div", text: "Peter Pepper")
    expect(page).to have_selector("div", text: "Date of birth: 1/11/1995")
    expect(page).to have_selector("div", text: "SSN: XXX-XX-4444")

    fill_in I18n.t("views.ctc.questions.confirm_information.labels.primary_ip_pin"), with: "12345"
    click_on "I'm ready to file"

    visit "en/questions/confirm-legal" # TODO: remove redirect when other review pages are in
    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_legal.title"))
    check I18n.t("views.ctc.questions.confirm_legal.consent")
    click_on I18n.t("views.ctc.questions.confirm_legal.action")

    # =========== PORTAL ===========
    expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
    expect(page).to have_text(I18n.t("views.ctc.portal.home.status.preparing.label"))
  end
end
