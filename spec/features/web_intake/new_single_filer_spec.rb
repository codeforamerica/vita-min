require "rails_helper"

RSpec.feature "Web Intake Single Filer" do
  let(:ticket_id) { 9876 }

  before do
    create :vita_partner, display_name: "Virginia Partner", zendesk_group_id: "123", states: [State.find_by(abbreviation: "VA")]
    allow_any_instance_of(ZendeskIntakeService).to receive(:assign_requester)
    allow_any_instance_of(ZendeskIntakeService).to receive(:create_intake_ticket).and_return(ticket_id)
  end

  scenario "new client filing single without dependents" do
    # Home
    visit "/"
    find("#firstCta").click

    # Welcome
    expect(page).to have_selector("h1", text: "Welcome! How can we help you?")
    click_on "File taxes with help"

    # File With Help
    expect(page).to have_selector("h1", text: "File with the help of a tax expert!")
    click_on "Continue"

    # Ask about backtaxes
    expect(page).to have_selector("h1", text: "What years do you need to file for?")

    check "2017"
    check "2019"
    click_on "Continue"

    #Non-production environment warning
    expect(page).to have_selector("h1", text: "Thanks for visiting the GetYourRefund demo application!")
    click_on "Continue to example"

    expect(page).to have_selector("h1", text: "Let's get started")
    click_on "Continue"

    # VITA eligibility checks
    expect(page).to have_selector("h1", text: "Let’s check a few things.")

    check "None of the above"
    click_on "Continue"

    # Overview
    expect(page).to have_selector("h1", text: "Just a few simple steps to file!")
    click_on "Continue"

    # Personal Info
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
    expect(page).to have_text("How can we update you on your tax return?")
    check "Email Me"
    check "Text Me"
    fill_in "Cell phone number", with: "555-231-4321"
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

    # right about here, our intake gets an intake_ticket_id in a background job
    allow_any_instance_of(Intake).to receive(:intake_ticket_id).and_return(ticket_id)

    # Primary filer personal information
    expect(page).to have_selector("h1", text: "Select any situations that were true for you in 2019")
    expect(track_progress).to eq(0)
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Have you ever been issued an IP PIN because of identity theft?")
    expect{ track_progress }.to change { @current_progress }.by_at_least(1)
    click_on "No"

    # Marital status
    expect(page).to have_selector("h1", text: "Have you ever been legally married?")
    click_on "No"

    # Dependents
    expect(page).to have_selector("h1", text: "Would you like to claim anyone for 2019?")
    click_on "No"

    # Related to dependents
    expect(page).to have_selector("h1", text: "In 2019, did you pay any child or dependent care expenses?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2019, did you adopt a child?")
    click_on "No"

    # Students
    expect(page).to have_selector("h1", text: "In 2019, was someone in your family a college or other post high school student?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2019, did you pay any student loan interest?")
    click_on "No"

    # Income from working
    select "3 jobs", from: "In 2019, how many jobs did you have?"
    click_on "Next"
    expect(page).to have_selector("h1", text: "In 2019, did you live or work in any other states besides Virginia?")
    click_on "No"
    expect(page).to have_selector("h1", text: "Tell us about your work in 2019")
    click_on "Continue"

    # Income from benefits
    expect(page).to have_selector("h1", text: "In 2019, did you receive any disability benefits?")
    click_on "No"

    # Investment income/loss
    expect(page).to have_selector("h1", text: "In 2019, did you have any income from interest or dividends?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2019, did you have any income from the sale of stocks, bonds, or real estate?")
    click_on "No"
    expect(page).to have_selector("h1", text: "Did you report a loss from the sale of stocks, bonds, or real estate on your 2018 return?")
    click_on "Yes"

    # Retirement income/contributions
    expect(page).to have_selector("h1", text: "In 2019, did you have any income from Social Security or Railroad Retirement Benefits?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2019, did you have any income from a retirement account, pension, or annuity proceeds?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2019, did you make any contributions to a retirement account?")
    click_on "Yes"

    # Other income
    expect(page).to have_selector("h1", text: "In 2019, did you receive any other money?")
    click_on "Yes"
    fill_in "What were the other types of income that you received?", with: "cash from gardening"
    click_on "Next"

    # Health insurance
    expect(page).to have_selector("h1", text: "In 2019, did you purchase health insurance through the marketplace or exchange?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2019, did you have a Health Savings Account?")
    click_on "No"

    # Itemizing
    expect(page).to have_selector("h1", text: "In 2019, did you pay any medical, dental, or prescription expenses?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2019, did you make any charitable contributions?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2019, did you have any income from gambling winnings, including the lottery?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2019, did you pay for any eligible school supplies as a teacher, teacher's aide, or other educator?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2019, did you pay any state, local, real estate, sales, or other taxes?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2019, did you receive a state or local income tax refund?")
    click_on "Yes"

    # Related to home ownership
    expect(page).to have_selector("h1", text: "In 2019, did you sell a home?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2019, did you pay any mortgage interest?")
    click_on "No"
    expect(page).to have_selector("h1", text: "Did you receive the First Time Homebuyer Credit in 2008?")
    click_on "Yes"

    # Miscellaneous
    expect(page).to have_selector("h1", text: "In 2019, did you have a loss related to a declared Federal Disaster Area?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2019, did you have debt cancelled or forgiven by a lender?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2019, did you receive any letter or bill from the IRS?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "Have you had the Earned Income Credit, Child Tax Credit, American Opportunity Credit, or Head of Household filing status disallowed in a prior year?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2019, did you make any estimated tax payments or apply your 2018 refund to your 2019 taxes?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "Did you report a business loss on your 2018 tax return?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2019, did you purchase energy efficient home items?")
    click_on "Yes"

    # Additional Information
    fill_in "Is there any more information you think we should know?", with: "One of my kids moved away for college, should I include them as a dependent?"
    expect{ track_progress }.to change { @current_progress }.to(100)
    click_on "Next"

    # Overview: Documents
    expect(page).to have_selector("h1", text: "Collect all your documents and have them with you.")
    click_on "Continue"

    # IRS guidance
    expect(page).to have_selector("h1", text: "First, we need to confirm your basic information.")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Attach a photo of your ID card")
    attach_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "attachments", "picture_id.jpg"))
    click_on "Upload"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Confirm your identity with a photo of yourself")
    click_on "Submit a photo"

    expect(page).to have_selector("h1", text: "Share a photo of yourself holding your ID card")
    attach_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "attachments", "picture_id.jpg"))
    click_on "Upload"
    click_on "Continue"

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

    expect(page).to have_selector("h1", text: "Great work! Here's a list of what we've collected.")
    click_on "I've shared all my documents"

    # Interview time preferences
    fill_in "Do you have any time preferences for your interview phone call?", with: "Wednesday or Tuesday nights"
    expect(page) .to have_select(
      "What is your preferred language for the review?", selected: "English"
    )
    select("Spanish", from: "What is your preferred language for the review?")
    click_on "Continue"

    # Payment info
    expect(page).to have_selector("h1", text: "If due a refund, how would like to receive it?")
    choose "Direct deposit (fastest)"
    click_on "Continue"
    # Savings Options
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
    expect(page).to have_selector("h1", text: "What is your race?")
    check "Asian"
    check "White"
    click_on "Continue"
    expect(page).to have_text("What is your ethnicity?")
    choose "Not Hispanic or Latino"
    click_on "Continue"

    # Additional Information
    fill_in "Anything else you'd like your tax preparer to know about your situation?", with: "Nope."
    click_on "Submit"

    expect(page).to have_selector("h1", text: "Success! Your tax information has been submitted.")
    expect(page).to have_text("Your confirmation number is: #{ticket_id}")
    click_on "Great!"

    fill_in "Thank you for sharing your experience.", with: "I am the single filer. I file alone."
    click_on "Return to home"
    expect(page).to have_selector("h1", text: "Free tax filing, real human support.")

    # going back to another page after submit redirects to beginning
    visit "/questions/work-situations"
    expect(page).to have_selector("h1", text: "Welcome! How can we help you?")
  end
end
