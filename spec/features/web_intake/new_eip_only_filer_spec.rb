require "rails_helper"

RSpec.feature "Web Intake EIP Only Filer" do
  let(:ticket_id) { 9876 }

  before do
    allow_any_instance_of(ZendeskIntakeService).to receive(:assign_requester)
    allow_any_instance_of(ZendeskIntakeService).to receive(:create_intake_ticket).and_return(ticket_id)
    # Create the hard-coded VITA partner for EIP-only returns
    create(:vita_partner, display_name: "Get Your Refund", zendesk_group_id: "360012655454")
  end

  scenario "new EIP-only client filing joint with a dependent" do
    # Home
    visit "/"
    find("#firstCta").click

    # Welcome
    expect(page).to have_selector("h1", text: "Welcome! How can we help you?")
    expect(page).to have_selector("h2", text: "Get your Stimulus")
    click_on("Get your Stimulus")

    expect(page).to have_selector("h1", text: "Have you already filed for 2018 and 2019?")
    click_on("Yes")

    expect(page).to have_selector("h1", text: "Do you need to correct your 2019 taxes?")
    click_on("No")

    expect(page).to have_selector("h1", text: "Have you already filed for 2017?")
    click_on("No")

    expect(page).to have_selector("h1", text: "We can help increase your cash support, by filing your taxes in addition to the stimulus")
    click_on("No. I only want my stimulus.")

    # Overview
    expect(page).to have_selector("h1", text: "Great! Let's help you collect your stimulus.")
    click_on "Continue"

    #Non-production environment warning
    expect(page).to have_selector("h1", text: "Thanks for visiting the GetYourRefund demo application!")
    click_on "Continue to example"

    # Eligibility Page
    expect(page).to have_selector("h1", text: "Before we start, let's make sure you qualify for our help!")
    check "None of the above"
    click_on "Collect my stimulus"

    # Personal Info
    expect(page).to have_selector("h1", text: "First, let's get some basic information.")
    fill_in "Preferred name", with: "Gary"
    fill_in "ZIP code", with: "20121"
    click_on "Continue"

    # Chat with us
    expect(page).to have_selector("h1", text: "Our team at Get Your Refund is here to help!")
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

    # Primary Personal Info
    expect(page).to have_selector("h1", text: "Have you ever been issued an IP PIN because of identity theft?")
    click_on "No"

    # Marital status
    expect(page).to have_selector("h1", text: "Have you ever been legally married?")
    click_on "Yes"

    # Filing status
    expect(page).to have_selector("h1", text: "Are you filing joint taxes with your spouse?")
    click_on "Yes"

    # Spouse email
    expect(page).to have_selector("h1", text: "Please share your spouse's e-mail address")
    fill_in "E-mail address", with: "greta.gardengnome@example.green"
    fill_in "Confirm e-mail address", with: "greta.gardengnome@example.green"
    click_on "Continue"

    # Spouse consent
    expect(page).to have_selector("h1", text: "We need your spouse to review our legal stuff...")
    fill_in "Spouse's legal first name", with: "Greta"
    fill_in "Spouse's legal last name", with: "Gnome"
    fill_in "Last 4 of SSN/ITIN", with: "1234"
    select "March", from: "Month"
    select "5", from: "Day"
    select "1971", from: "Year"
    click_on "I agree"

    # Spouse Personal Info
    expect(page).to have_selector("h1", text: "Has your spouse been issued an Identity Protection PIN?")
    click_on "No"

    # Dependents
    expect(page).to have_selector("h1", text: "Would you or your spouse like to claim anyone for 2019?")
    click_on "Yes"

    click_on "Add a person"
    fill_in "First name", with: "Gallagher"
    fill_in "Last name", with: "Gnome"
    select "November", from: "Month"
    select "24", from: "Day"
    select "2005", from: "Year"
    fill_in "Relationship to you", with: "Nibling"
    select "2", from: "How many months did they live in your home in 2019?"
    check "Is this person here on a VISA?"
    check "Married as of 12/31/2019"
    click_on "Save this person"
    expect(page).to have_text("Gallagher Gnome")

    click_on "Done with this step"

    # Additional Information
    fill_in "Is there any more information you think we should know?", with: "One of my kids moved away for college, should I include them as a dependent?"
    expect{ track_progress }.to change { @current_progress }.to(100)
    click_on "Next"

    # IRS guidance
    expect(page).to have_selector("h1", text: "First, we need to confirm your basic information.")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Attach photos of ID cards")
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
    expect(page).to have_selector("h1", text: "What is your spouse's race?")
    check "Asian"
    check "White"
    click_on "Continue"
    expect(page).to have_text("What is your ethnicity?")
    choose "Not Hispanic or Latino"
    click_on "Continue"
    expect(page).to have_selector("h1", text: "What is your spouse's ethnicity?")
    choose "Not Hispanic or Latino"
    click_on "Continue"

    # Additional Information
    fill_in "Anything else you'd like your tax preparer to know about your situation?", with: "Nope."
    click_on "Submit"

    expect(page).to have_selector("h1", text: "Success! Your tax information has been submitted.")
    expect(page).to have_text("Your confirmation number is: #{ticket_id}")
    click_on "Great!"

    fill_in "Thank you for sharing your experience.", with: "I wish to file as speedily as possible!"
    click_on "Return to home"
    expect(page).to have_selector("h1", text: "Free tax filing, real human support.")

    # going back to another page after submit redirects to beginning
    visit "/questions/wages"
    expect(page).to have_selector("h1", text: "Welcome! How can we help you?")
  end

  scenario "ineligible for EIP" do
    visit "/questions/eip-overview"
    expect(page).to have_selector("h1", text: "Great! Let's help you collect your stimulus.")
    click_on "Continue"

    # Non-production environment warning
    expect(page).to have_selector("h1", text: "Thanks for visiting the GetYourRefund demo application!")
    click_on "Continue to example"

    # Eligibility Page
    expect(page).to have_selector("h1", text: "Before we start, let's make sure you qualify for our help!")
    check "Someone else is claiming me on their taxes"
    click_on "Collect my stimulus"

    # Offboarding page
    expect(page).to have_selector("h1", text: "Unfortunately, you don't qualify for our assistance")
    click_on "Visit Stimulus FAQ"

    # Stimulus FAQ
    expect(page).to have_selector("h1", text: "Get your Stimulus Check")
  end
end
