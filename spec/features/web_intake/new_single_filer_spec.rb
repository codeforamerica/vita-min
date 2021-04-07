require "rails_helper"

RSpec.feature "Web Intake Single Filer", active_job: true do
  let(:ticket_id) { 9876 }

  before do
    create :vita_partner, name: "Virginia Partner", national_overflow_location: true
  end

  scenario "new client filing single without dependents" do
    visit "/en/questions/welcome"

    # Welcome
    expect(page).to have_selector("h1", text: "Welcome! How can we help you?")
    within ".main-header" do
      expect(page).to have_text("Sign in")
    end
    click_on "File taxes with help"

    # File With Help
    expect(page).to have_selector("h1", text: "File with the help of a tax expert!")
    click_on "Continue"

    # Ask about backtaxes
    expect(page).to have_selector("h1", text: "What years do you need to file for?")

    check "2020"
    check "2017"
    click_on "Continue"
    intake = Intake.last

    expect(intake.client.tax_returns.pluck(:year).sort).to eq [2017, 2020]

    #Non-production environment warning
    expect(page).to have_selector("h1", text: "Thanks for visiting the GetYourRefund demo application!")
    click_on "Continue to example"

    expect(page).to have_selector("h1", text: "Let's get started")
    expect(page).to have_text("We’ll start by asking about your situation in 2020.")
    click_on "Continue"

    # VITA eligibility checks
    expect(page).to have_selector("h1", text: "Let’s check a few things.")
    expect(intake.reload.current_step).to eq("/en/questions/eligibility")

    check "None of the above"
    click_on "Continue"

    # Overview
    expect(page).to have_selector("h1", text: "Just a few simple steps to file!")
    click_on "Continue"

    # Personal Info
    expect(intake.reload.current_step).to eq("/en/questions/personal-info")
    expect(page).to have_selector("h1", text: "First, let's get some basic information.")
    fill_in "Preferred name", with: "Gary"
    fill_in "ZIP code", with: "20121"
    click_on "Continue"

    # Chat with us
    expect(page).to have_selector("h1", text: "Our team at Virginia Partner is here to help!")
    expect(page).to have_selector("p", text: "Virginia Partner handles tax returns from 20121 (Centreville, Virginia).")
    click_on "Continue"

    # Phone number
    expect(page).to have_selector("h1", text: "Please share your contact number.")
    fill_in "Phone number", with: "(415) 553-7865"
    fill_in "Confirm phone number", with: "(415) 553-7865"
    check "This number can receive text messages"
    click_on "Continue"

    # Email
    expect(page).to have_selector("h1", text: "Please share your e-mail address.")
    fill_in "E-mail address", with: "gary.gardengnome@example.green"
    fill_in "Confirm e-mail address", with: "gary.gardengnome@example.green"
    click_on "Continue"

    # Notification Preference
    expect(intake.reload.current_step).to eq("/en/questions/notification-preference")
    expect(page).to have_text("How can we update you on your tax return?")
    check "Email Me"
    check "Text Me"
    fill_in "Cell phone number", with: "(415) 553-7865"
    click_on "Continue"

    # Consent form
    expect(page).to have_selector("h1", text: "Great! Here's the legal stuff...")
    fill_in "Legal first name", with: "Gary"
    fill_in "Legal last name", with: "Gnome"
    fill_in "Last 4 of SSN/ITIN", with: "1234"
    select "March", from: "Month"
    select "5", from: "Day"
    select "1971", from: "Year"
    click_on "I agree"

    # Optional consent form
    expect(page).to have_selector("h1", text: "A few more things...")
    expect(page).to have_checked_field("Consent to Use")
    expect(page).to have_link("Consent to Use", href: consent_to_use_path)
    expect(page).to have_checked_field("Consent to Disclose")
    expect(page).to have_link("Consent to Disclose", href: consent_to_disclose_path)
    expect(page).to have_checked_field("Relational EFIN")
    expect(page).to have_link("Relational EFIN", href: relational_efin_path)
    expect(page).to have_checked_field("Global Carryforward")
    expect(page).to have_link("Global Carryforward", href: global_carryforward_path)
    uncheck "Global Carryforward"
    click_on "Continue"

    # Primary filer personal information
    expect(page).to have_selector("h1", text: "Select any situations that were true for you in 2020")
    expect(track_progress).to eq(0)
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Did you receive an Economic Impact Payment (stimulus) in 2020?")
    expect{ track_progress }.to change { @current_progress }.by_at_least(1)
    click_on "Yes"

    expect(page).to have_selector("h1", text: "Have you ever been issued an IP PIN because of identity theft?")
    expect{ track_progress }.to change { @current_progress }.by_at_least(1)
    click_on "No"

    # Marital status
    expect(page).to have_selector("h1", text: "Have you ever been legally married?")
    click_on "No"

    # Dependents
    expect(intake.reload.current_step).to eq("/en/questions/had-dependents")
    expect(page).to have_selector("h1", text: "Would you like to claim anyone for 2020?")
    click_on "No"

    # Related to dependents
    expect(page).to have_selector("h1", text: "In 2020, did you pay any child or dependent care expenses?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2020, did you adopt a child?")
    click_on "No"

    # Students
    expect(page).to have_selector("h1", text: "In 2020, was someone in your family a college or other post high school student?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2020, did you pay any student loan interest?")
    click_on "No"

    # Income from working
    expect(intake.reload.current_step).to eq("/en/questions/job-count")
    select "3 jobs", from: "In 2020, how many jobs did you have?"
    click_on "Next"
    expect(page).to have_selector("h1", text: "In 2020, did you live or work in any other states besides Virginia?")
    click_on "No"
    expect(page).to have_selector("h1", text: "Tell us about your work in 2020")
    click_on "Continue"

    # Income from benefits
    expect(page).to have_selector("h1", text: "In 2020, did you receive any disability benefits?")
    click_on "No"

    # Investment income/loss
    expect(page).to have_selector("h1", text: "In 2020, did you have any income from interest or dividends?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2020, did you sell any stocks, bonds, or real estate?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2020, did you have any income from the sale of stocks, bonds, or real estate?")
    click_on "No"
    expect(page).to have_selector("h1", text: "Did you report a loss from the sale of stocks, bonds, or real estate on your 2019 return?")
    click_on "Yes"

    # Retirement income/contributions
    expect(intake.reload.current_step).to eq("/en/questions/social-security-or-retirement")
    expect(page).to have_selector("h1", text: "In 2020, did you have Social Security income, retirement income, or retirement contributions?")
    click_on "No"

    # Other income
    expect(page).to have_selector("h1", text: "In 2020, did you receive any other money?")
    click_on "Yes"
    fill_in "What were the other types of income that you received?", with: "cash from gardening"
    click_on "Next"

    # Health insurance
    expect(page).to have_selector("h1", text: "In 2020, did you purchase health insurance through the marketplace or exchange?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2020, did you have a Health Savings Account?")
    click_on "No"

    # Itemizing
    expect(page).to have_selector("h1", text: "In 2020, did you pay any medical, dental, or prescription expenses?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2020, did you make any charitable contributions?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2020, did you have any income from gambling winnings, including the lottery?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2020, did you pay for any eligible school supplies as a teacher, teacher's aide, or other educator?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2020, did you pay any state, local, real estate, sales, or other taxes?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2020, did you receive a state or local income tax refund?")
    click_on "Yes"

    # Related to home ownership
    expect(page).to have_selector("h1", text: "In 2020, did you sell a home?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2020, did you pay any mortgage interest?")
    click_on "No"
    expect(page).to have_selector("h1", text: "Did you receive the First Time Homebuyer Credit in 2008?")
    click_on "Yes"

    # Miscellaneous
    expect(intake.reload.current_step).to eq("/en/questions/disaster-loss")
    expect(page).to have_selector("h1", text: "In 2020, did you have a loss related to a declared Federal Disaster Area?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2020, did you have debt cancelled or forgiven by a lender?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2020, did you receive any letter or bill from the IRS?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "Have you had the Earned Income Credit, Child Tax Credit, American Opportunity Credit, or Head of Household filing status disallowed in a prior year?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2020, did you make any estimated tax payments or apply your 2019 refund to your 2020 taxes?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "Did you report a business loss on your 2019 tax return?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2020, did you purchase energy efficient home items?")
    click_on "Yes"

    # Additional Information
    fill_in "Is there any more information you think we should know?", with: "One of my kids moved away for college, should I include them as a dependent?"
    click_on "Next"

    # Overview: Documents
    expect(intake.reload.current_step).to eq("/en/questions/overview-documents")

    expect(page).to have_selector("h1", text: "Collect all your documents and have them with you.")
    click_on "Continue"

    # IRS guidance
    expect(page).to have_selector("h1", text: "First, we need to confirm your basic information.")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Attach a photo of your ID card")
    attach_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "attachments", "picture_id.jpg"))
    click_on "Upload"
    click_on "Continue"

    expect(intake.reload.current_step).to eq("/en/documents/selfie-instructions")
    expect(page).to have_selector("h1", text: "Confirm your identity with a photo of yourself")
    click_on "Submit a photo"

    expect(intake.reload.current_step).to eq("/en/documents/selfies")
    expect(page).to have_selector("h1", text: "Share a photo of yourself holding your ID card")
    attach_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "attachments", "picture_id.jpg"))
    click_on "Upload"
    click_on "Continue"

    expect(intake.reload.current_step).to eq("/en/documents/ssn-itins")
    expect(page).to have_selector("h1", text: "Attach photos of Social Security Card or ITIN")
    attach_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "attachments", "picture_id.jpg"))
    click_on "Upload"
    click_on "Continue"

    # Documents: Intro
    expect(page).to have_selector("h1", text: "Now, let's collect your tax documents!")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Share your employment documents")
    attach_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))
    click_on "Upload"

    expect(page).to have_content("test-pattern.png")
    expect(page).to have_link("Remove")

    attach_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "attachments", "picture_id.jpg"))
    click_on "Upload"

    expect(page).to have_content("test-pattern.png")
    expect(page).to have_content("picture_id.jpg")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Please share any additional documents.")
    attach_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))
    click_on "Upload"
    expect(page).to have_content("test-pattern.png")
    click_on "Continue"

    expect(intake.reload.current_step).to eq("/en/documents/overview")
    expect(page).to have_selector("h1", text: "Great work! Here's a list of what we've collected.")
    click_on "I've shared all my documents"

    # Interview time preferences
    expect(intake.reload.current_step).to eq("/en/questions/interview-scheduling")
    fill_in "Do you have any time preferences for your interview phone call?", with: "Wednesday or Tuesday nights"
    expect(page).to have_select(
      "What is your preferred language for the review?", selected: "English"
    )
    select("Spanish", from: "What is your preferred language for the review?")
    click_on "Continue"

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
    click_on "Continue"

    # Additional Information
    fill_in "Anything else you'd like your tax preparer to know about your situation?", with: "Nope."
    expect do
      click_on "Submit"
    end.to change(OutgoingTextMessage, :count).by(1).and change(OutgoingEmail, :count).by(1)

    expect(intake.reload.current_step).to eq("/en/questions/successfully-submitted")
    expect(page).to have_selector("h1", text: "Success! Your tax information has been submitted.")
    expect(page).to have_text("Your confirmation number is: #{intake.client_id}")
    expect{ track_progress }.to change { @current_progress }.to(100)
    click_on "Great!"

    expect(intake.reload.current_step).to eq("/en/questions/feedback")
    fill_in "Thank you for sharing your experience.", with: "I am the single filer. I file alone."
    click_on "Return to home"
    expect(page).to have_selector("h1", text: "Free tax filing")

    # going back to another page after submit redirects to client login, does not reset current_step
    visit "/questions/work-situations"
    expect(intake.reload.current_step).to eq("/en/questions/feedback")
    expect(page).to have_selector("h1", text: "To view your progress, we’ll send you a secure code.")

    visit intake.requested_docs_token_link
    expect(intake.reload.current_step).to eq("/en/questions/feedback")
  end
end
