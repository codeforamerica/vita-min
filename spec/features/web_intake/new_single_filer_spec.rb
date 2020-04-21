require "rails_helper"

RSpec.feature "Web Intake Single Filer" do
  before do
    allow_any_instance_of(ZendeskIntakeService).to receive(:create_intake_ticket_requester).and_return(4321)
    allow_any_instance_of(ZendeskIntakeService).to receive(:create_intake_ticket).and_return(9876)
  end

  scenario "new client filing single without dependents" do
    # Feelings
    visit "/questions/feelings"
    expect(page).to have_selector("h1", text: "How are you feeling about your taxes?")
    choose "Sad face"
    click_on "Start my taxes online"

    # Ask about backtaxes
    expect(page).to have_selector("h1", text: "What years do you need to file for?")
    check "2017"
    check "2019"
    click_on "Continue"
    expect(page).to have_selector("h1", text: "Let's get started")
    click_on "Continue"

    # Chat with us
    expect(page).to have_selector("h1", text: "Our team is here to help!")
    click_on "Continue"

    # VITA eligibility checks
    expect(page).to have_selector("h1", text: "Let’s check a few things.")
    check "None of the above"
    click_on "Continue"

    # Overview
    expect(page).to have_selector("h1", text: "Just a few simple steps to file!")
    click_on "Continue"

    # Documents overview
    expect(page).to have_selector("h1", text: "Collect all your documents and have them with you.")
    click_on "Continue"

    # Personal Info
    expect(page).to have_selector("h1", text: "First, let's get some basic information.")
    fill_in "Preferred name", with: "Gary"
    select "Indiana", from: "State of residence"
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

    # Authentication
    expect(page).to have_selector("h1", text: "First, let’s get some basic information.")
    click_on "Sign in with ID.me"

    # the ID.me flow would occur here. They should end up back on a success page.

    # Consent form
    expect(page).to have_selector("h1", text: "Great! Here's the legal stuff...")
    fill_in "Legal full name", with: "Gary Gnome"
    fill_in "Last 4 of SSN/ITIN", with: "1234"
    select "March", from: "Month"
    select "5", from: "Day"
    select "1971", from: "Year"
    click_on "I agree"

    # Contact information
    expect(page).to have_text("What is your mailing address?")
    fill_in "Street address", with: "123 Main St."
    fill_in "City", with: "Anytown"
    select "California", from: "State"
    fill_in "ZIP code", with: "94612"
    click_on "Confirm"

    expect(page).to have_text("How can we update you on your tax return?")
    check "Email Me"
    check "Text Me"
    fill_in "Cell phone number", with: "555-231-4321"
    click_on "Continue"

    # Primary filer personal information
    expect(page).to have_selector("h1", text: "Were you a full-time student in 2019?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2019, were you in the United States on a Visa?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2019, did you have a permanent disability?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2019, were you legally blind?")
    click_on "No"
    expect(page).to have_selector("h1", text: "Have you ever been issued an Identity Protection PIN?")
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
    expect(page).to have_selector("h1", text: "In 2019, did you live or work in any other states besides Indiana?")
    click_on "No"
    expect(page).to have_selector("h1", text: "In 2019, did you receive wages or salary?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2019, did you have any income from contract or self-employment work?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2019, did you receive any tips?")
    click_on "Yes"

    # Income from benefits
    expect(page).to have_selector("h1", text: "In 2019, did you receive any unemployment benefits?")
    click_on "No"
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
    fill_in "Is there any additional information you think we should know?", with: "One of my kids moved away for college, should I include them as a dependent?"
    click_on "Next"

    # Documents overview
    expect(page).to have_selector("h1", text: "All right, let's collect your documents!")
    click_on "Continue"

    # IRS guidance
    expect(page).to have_selector("h1", text: "First, we need to confirm your basic information.")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Attach a photo of your ID card")
    attach_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "attachments", "picture_id.jpg"))
    click_on "I'm done for now"

    expect(page).to have_selector("h1", text: "Attach photos of Social Security Card or ITIN")
    click_on "I'm done for now"

    expect(page).to have_selector("h1", text: "Confirm your identity with a selfie")
    click_on "Submit a selfie"

    expect(page).to have_selector("h1", text: "Share a selfie with your ID card")
    click_on "I'm done for now"

    expect(page).to have_selector("h1", text: "Attach your W-2's")
    attach_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))
    click_on "Upload"

    expect(page).to have_content("test-pattern.png")
    expect(page).to have_link("Remove")

    attach_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "attachments", "picture_id.jpg"))
    click_on "Upload"

    expect(page).to have_content("test-pattern.png")
    expect(page).to have_content("picture_id.jpg")
    click_on "I'm done for now"

    expect(page).to have_selector("h1", text: "Attach your 1098's")
    click_on "I'm done for now"

    expect(page).to have_selector("h1", text: "Attach your 1098-T's")
    click_on "I'm done for now"

    expect(page).to have_selector("h1", text: "Attach your 1099-K's")
    click_on "I'm done for now"

    expect(page).to have_selector("h1", text: "Attach your 1099-MISC's")
    click_on "I don't have this document"

    expect(page).to have_selector("h1", text: "Attach your IRA Statements")
    click_on "I'm done for now"

    expect(page).to have_selector("h1", text: "Attach your Property Tax Statements")
    click_on "I'm done for now"

    expect(page).to have_selector("h1", text: "Attach your student account statements")
    click_on "I don't have this document"

    expect(page).to have_selector("h1", text: "Attach your statements from childcare facilities or individuals who provided care.")
    click_on "I don't have this document"

    expect(page).to have_selector("h1", text: "Attach your 2018 tax return")
    click_on "I'm done for now"

    expect(page).to have_selector("h1", text: "Do you have any additional documents?")
    attach_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))
    click_on "Upload"
    expect(page).to have_content("test-pattern.png")
    click_on "I'm done for now"

    expect(page).to have_selector("h1", text: "Great work! Here's a list of what we've collected.")
    click_on "I'm done"

    # Interview time preferences
    fill_in "Do you have any time preferences for your interview phone call?", with: "Wednesday or Tuesday nights"
    click_on "Continue"

    # Payment info
    expect(page).to have_selector("h1", text: "If due a refund, how would like to receive it?")
    choose "Direct deposit (fastest)"
    click_on "Continue"
    expect(page).to have_selector("h1", text: "If due a refund, are you interested in using these savings options?")
    check "Purchase United States Savings Bond"
    click_on "Continue"
    expect(page).to have_selector("h1", text: "If you have a balance due, would you like to make a payment directly from your bank account?")
    click_on "Yes"

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

    expect(page).to have_selector("h1", text: "Your tax information has been successfully submitted!")
  end
end
