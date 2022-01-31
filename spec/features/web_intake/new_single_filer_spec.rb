require "rails_helper"

RSpec.feature "Web Intake Single Filer", :flow_explorer_screenshot, active_job: true do
  include MockTwilio

  let!(:vita_partner) { create :organization, name: "Virginia Partner" }
  let!(:vita_partner_zip_code) { create :vita_partner_zip_code, zip_code: "20121", vita_partner: vita_partner }

  scenario "new client filing single without dependents" do
    answer_gyr_triage_questions(choices: :defaults)

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_gyr.edit.title'))
    click_on I18n.t('questions.triage_gyr.edit.file_online')

    # Ask about backtaxes
    expect(page).to have_selector("h1", text: I18n.t("views.questions.backtaxes.title"))
    check "#{TaxReturn.current_tax_year}"
    check "#{TaxReturn.current_tax_year - 3}"
    click_on "Continue"
    # creates intake
    intake = Intake.last

    # Non-production environment warning
    expect(page).to have_text I18n.t('views.questions.environment_warning.title')
    click_on I18n.t('general.continue_example')

    expect(page).to have_selector("h1", text: "Let's get started")
    expect(page).to have_text("We’ll start by asking about your situation in #{TaxReturn.current_tax_year}.")
    click_on "Continue"

    # Overview
    expect(page).to have_selector("h1", text: "Just a few simple steps to file!")
    click_on "Continue"

    # Personal Info
    expect(intake.reload.current_step).to eq("/en/questions/personal-info")
    expect(page).to have_selector("h1", text: "First, let's get some basic information.")
    fill_in "What is your preferred first name?", with: "Gary"
    fill_in "Phone number", with: "8286345533"
    fill_in "Confirm phone number", with: "828-634-5533"
    fill_in "ZIP code", with: "20121"
    click_on "Continue"

    # Interview time preferences
    expect(intake.reload.current_step).to eq("/en/questions/interview-scheduling")
    fill_in "Do you have any time preferences for your interview phone call?", with: "Wednesday or Tuesday nights"
    expect(page).to have_select(
      "What is your preferred language for the review?", selected: "English"
    )
    select("Spanish", from: "What is your preferred language for the review?")
    click_on "Continue"

    # Notification Preference
    expect(intake.reload.current_step).to eq("/en/questions/notification-preference")
    expect(page).to have_text("What ways can we reach you")
    expect(page).to have_text("We’ll send a code to verify each contact method")
    check "Email Me"
    check "Text Me"
    click_on "Continue"

    # Phone number can text
    expect(page).to have_text("Can we text the phone number you previously entered?")
    expect(page).to have_text("(828) 634-5533")
    expect(page).to have_text("Please be sure that this number can receive text messages.")
    click_on "No"

    # Phone number
    expect(page).to have_selector("h1", text: "Please share your cell phone number.")
    fill_in "Cell phone number", with: "(415) 553-7865"
    fill_in "Confirm cell phone number", with: "+1415553-7865"
    click_on "Continue"

    # Verify cell phone contact
    expect(page).to have_selector("h1", text: "Let's verify that contact info with a code!")
    perform_enqueued_jobs
    sms = FakeTwilioClient.messages.last
    code = sms.body.to_s.match(/\s(\d{6})[.]/)[1]
    fill_in "Enter 6 digit code", with: code
    click_on "Verify"

    # Email
    expect(page).to have_selector("h1", text: "Please share your email address.")
    fill_in "Email address", with: "gary.gardengnome@example.green"
    fill_in "Confirm email address", with: "gary.gardengnome@example.green"
    click_on "Continue"

    # Verify email contact
    expect(page).to have_selector("h1", text: "Let's verify that contact info with a code!")
    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]
    fill_in "Enter 6 digit code", with: code
    click_on "Verify"

    # Consent form
    expect(page).to have_selector("h1", text: I18n.t('views.questions.consent.title'))
    fill_in I18n.t("views.questions.consent.primary_first_name"), with: "Gary"
    fill_in I18n.t("views.questions.consent.primary_last_name"), with: "Gnome"
    fill_in I18n.t("attributes.primary_ssn"), with: "123-45-6789"
    fill_in I18n.t("attributes.confirm_primary_ssn"), with: "123-45-6789"
    select I18n.t("date.month_names")[3], from: "consent_form_birth_date_month"
    select "5", from: "consent_form_birth_date_day"
    select "1971", from: "consent_form_birth_date_year"
    click_on I18n.t("views.questions.consent.cta")
    # create tax returns only after client has consented
    expect(intake.client.tax_returns.pluck(:year).sort).to eq [TaxReturn.current_tax_year - 3, TaxReturn.current_tax_year]

    # Optional consent form
    expect(page).to have_selector("h1", text: I18n.t('views.questions.optional_consent.title'))
    toggles = {
      strip_html_tags(I18n.t('views.questions.optional_consent.consent_to_use_html')).split(':').first => consent_to_use_path,
      strip_html_tags(I18n.t('views.questions.optional_consent.consent_to_disclose_html')).split(':').first => consent_to_disclose_path,
      strip_html_tags(I18n.t('views.questions.optional_consent.relational_efin_html')).split(':').first => relational_efin_path,
      strip_html_tags(I18n.t('views.questions.optional_consent.global_carryforward_html')).split(':').first => global_carryforward_path,
    }
    toggles.each do |toggle_text, link_path|
      expect(page).to have_checked_field(toggle_text)
      expect(page).to have_link(toggle_text, href: link_path)
    end
    uncheck toggles.keys.last
    click_on I18n.t('general.continue')

    # Chat with us
    expect(page).to have_selector("h1", text: "Our team at Virginia Partner is here to help!")
    expect(page).to have_selector("p", text: "Virginia Partner handles tax returns from 20121 (Centreville, Virginia).")
    click_on "Continue"

    # Primary filer personal information
    expect(page).to have_selector("h1", text: "Select any situations that were true for you in #{TaxReturn.current_tax_year}")
    expect(track_progress).to eq(0)
    click_on "Continue"

    expect(page).to have_selector("h1", text: I18n.t("views.questions.arp_payments.title"))
    expect { track_progress }.to change { @current_progress }.by_at_least(1)
    fill_in I18n.t("views.questions.arp_payments.labels.stimulus_1"), with: 800
    fill_in I18n.t("views.questions.arp_payments.labels.stimulus_2"), with: 1000
    fill_in I18n.t("views.questions.arp_payments.labels.stimulus_3"), with: 0
    fill_in I18n.t("views.questions.arp_payments.labels.child_tax_credit"), with: 0
    check I18n.t("views.questions.arp_payments.labels.ctc_unsure")
    check I18n.t("views.questions.arp_payments.labels.stimulus_unsure")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Have you ever been issued an IP PIN because of identity theft?")
    expect { track_progress }.to change { @current_progress }.by_at_least(1)
    click_on "No"

    # Marital status
    expect(page).to have_selector("h1", text: "Have you ever been legally married?")
    click_on "No"

    # Dependents
    expect(intake.reload.current_step).to eq("/en/questions/had-dependents")
    expect(page).to have_selector("h1", text: "Would you like to claim anyone for #{TaxReturn.current_tax_year}?")
    click_on "No"

    # Related to dependents
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you pay any child or dependent care expenses?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you adopt a child?")
    click_on "No"

    # Students
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, was someone in your family a college or other post high school student?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you pay any student loan interest?")
    click_on "No"

    # Income from working
    expect(intake.reload.current_step).to eq("/en/questions/job-count")
    select "3 jobs", from: "In #{TaxReturn.current_tax_year}, how many jobs did you have?"
    click_on "Next"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you live or work in any other states besides Virginia?")
    click_on "No"
    expect(page).to have_selector("h1", text: "Tell us about your work in #{TaxReturn.current_tax_year}")
    click_on "Continue"

    # Income from benefits
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you receive any disability benefits?")
    click_on "No"

    # Investment income/loss
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you have any income from interest or dividends?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you sell any stocks, bonds, or real estate?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you have any income from the sale of stocks, bonds, or real estate?")
    click_on "No"
    expect(page).to have_selector("h1", text: "Did you report a loss from the sale of stocks, bonds, or real estate on your #{TaxReturn.current_tax_year - 1} return?")
    click_on "Yes"

    # Retirement income/contributions
    expect(intake.reload.current_step).to eq("/en/questions/social-security-or-retirement")
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you have Social Security income, retirement income, or retirement contributions?")
    click_on "No"

    # check for gating logic
    expect(intake.reload.had_social_security_income).to eq "no"
    expect(intake.reload.had_retirement_income).to eq "no"
    expect(intake.reload.paid_retirement_contributions).to eq "no"

    # Other income
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you receive any other money?")
    click_on "Yes"
    fill_in "What were the other types of income that you received?", with: "cash from gardening"
    click_on "Next"

    # Health insurance
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you purchase health insurance through the marketplace or exchange?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you have a Health Savings Account?")
    click_on "No"

    # Itemizing
    expect(page).to have_selector("h1", text: "Would you like to itemize your deductions for #{TaxReturn.current_tax_year}?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you pay any medical, dental, or prescription expenses?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you make any charitable contributions?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you have any income from gambling winnings, including the lottery?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you pay for any eligible school supplies as a teacher, teacher's aide, or other educator?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you pay any state, local, real estate, sales, or other taxes?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you receive a state or local income tax refund?")
    click_on "Yes"

    # Related to home ownership
    expect(page).to have_selector("h1", text: "Have you ever owned a home?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you sell a home?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you pay any mortgage interest?")
    click_on "No"
    expect(page).to have_selector("h1", text: "Did you receive the First Time Homebuyer Credit in 2008?")
    click_on "Yes"

    # Miscellaneous
    expect(intake.reload.current_step).to eq("/en/questions/disaster-loss")
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you have a loss related to a declared Federal Disaster Area?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you have debt cancelled or forgiven by a lender?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you receive any letter or bill from the IRS?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "Have you had the Earned Income Credit, Child Tax Credit, American Opportunity Credit, or Head of Household filing status disallowed in a prior year?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you make any estimated tax payments or apply your #{TaxReturn.current_tax_year - 1} refund to your #{TaxReturn.current_tax_year} taxes?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "Did you report a business loss on your #{TaxReturn.current_tax_year - 1} tax return?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you purchase energy efficient home items?")
    click_on "Yes"

    # Payment info
    expect(page).to have_selector("h1", text: "If due a refund, how would like to receive it?")
    choose "Direct deposit (fastest)"
    click_on "Continue"
    # Savings Options
    expect(intake.reload.current_step).to eq("/en/questions/savings-options")
    expect(page).to have_selector("h1", text: "If due a refund, are you interested in using these savings options?")
    check "Purchase United States Savings Bond"
    click_on "Continue"
    # Pay from bank account?
    expect(page).to have_selector("h1", text: "If you have a balance due, would you like to make a payment directly from your bank account?")
    click_on "Yes"
    # Bank Details
    expect(page).to have_selector("h1", text: "Great, please provide your bank details below!")
    fill_in "Bank name", with: "First Savings Bank"
    fill_in "Routing number", with: "123456"
    fill_in "Account number", with: "987654321"
    choose "Checking"
    click_on "Continue"

    # Contact information
    expect(intake.reload.current_step).to eq("/en/questions/mailing-address")
    expect(page).to have_text("What is your mailing address?")
    fill_in "Street address", with: "123 Main St."
    fill_in "City", with: "Anytown"
    select "California", from: "State"
    fill_in "ZIP code", with: "94612"
    click_on "Confirm"

    # Overview: Documents
    expect(intake.reload.current_step).to eq("/en/questions/overview-documents")

    expect(page).to have_selector("h1", text: "Collect all your documents and have them with you.")
    click_on "Continue"

    # IRS guidance
    expect(page).to have_selector("h1", text: "First, we need to confirm your basic information.")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Attach a photo of your ID card")
    expect(page).to have_text("We accept: .jpg, .jpeg, .png, .pdf, .heic, .bmp, .txt, .tiff, .gif")
    upload_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))
    click_on "Continue"

    expect(intake.reload.current_step).to eq("/en/documents/selfie-instructions")
    expect(page).to have_selector("h1", text: "Confirm your identity with a photo of yourself")
    click_on "Submit a photo"

    expect(intake.reload.current_step).to eq("/en/documents/selfies")
    expect(page).to have_selector("h1", text: "Share a photo of yourself holding your ID card")
    upload_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))
    click_on "Continue"

    expect(intake.reload.current_step).to eq("/en/documents/ssn-itins")
    expect(page).to have_selector("h1", text: "Attach photos of Social Security Card or ITIN")
    upload_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))
    click_on "Continue"

    # Documents: Intro
    expect(page).to have_selector("h1", text: "Now, let's collect your tax documents!")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Share your employment documents")
    upload_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "files", "test-pattern.png"))

    expect(page).to have_content("test-pattern.png")
    expect(page).to have_link("Remove")

    upload_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))

    expect(page).to have_content("test-pattern.png")
    expect(page).to have_content("picture_id.jpg")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Please share any additional documents.")
    upload_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "files", "test-pattern.png"))
    expect(page).to have_content("test-pattern.png")
    click_on "Continue"

    expect(intake.reload.current_step).to eq("/en/documents/overview")
    expect(page).to have_selector("h1", text: "Great work! Here's a list of what we've collected.")
    click_on "I've shared all my documents"

    # Final Information
    expect(intake.reload.current_step).to eq("/en/questions/final-info")
    fill_in "Anything else you'd like your tax preparer to know about your situation?", with: "One of my kids moved away for college, should I include them as a dependent?"
    expect {
      click_on "Submit"
    }.to change(OutgoingTextMessage, :count).by(1).and change(OutgoingEmail, :count).by(1)

    expect(intake.reload.current_step).to eq("/en/questions/successfully-submitted")
    expect(page).to have_selector("h1", text: "Success! Your tax information has been submitted.")
    expect(page).to have_text("Your confirmation number is: #{intake.client_id}")
    click_on "Great!"

    expect(intake.reload.current_step).to eq("/en/questions/feedback")
    fill_in "Thank you for sharing your experience.", with: "I am the single filer. I file alone."
    click_on "Continue"

    # Demographic questions
    expect(page).to have_selector("h1", text: "Are you willing to answer some additional questions to help us better serve you?")
    click_on "Continue"
    expect(page).to have_text("How well would you say you can carry on a conversation in English?")
    choose "Well"
    click_on "Continue"
    expect(page).to have_text("How well would you say you read a newspaper in English?")
    choose "Not well"
    click_on "Continue"
    expect(page).to have_text("Do you or any member of your household have a disability?")
    choose "No"
    click_on "Continue"
    expect(page).to have_text("Are you or your spouse a veteran of the U.S. Armed Forces?")
    choose "Yes"
    click_on "Continue"
    expect(intake.reload.current_step).to eq("/en/questions/demographic-primary-race")
    expect(page).to have_selector("h1", text: "What is your race?")
    check "Asian"
    check "White"
    click_on "Continue"
    expect(page).to have_text("What is your ethnicity?")
    choose "Not Hispanic or Latino"
    click_on "Submit"

    expect(page).to have_selector("h1", text: "Free tax filing")

    # going back to another page after submit redirects to client login, does not reset current_step
    visit "/questions/work-situations"
    expect(intake.reload.current_step).to eq("/en/questions/demographic-primary-ethnicity")
    expect(page).to have_selector("h1", text: "To view your progress, we’ll send you a secure code.")
  end
end
