require "rails_helper"

RSpec.feature "Web Intake Joint Filers" do
  let(:spouse_auth_hash) do
    OmniAuth::AuthHash.new({
      provider: "idme",
      uid: "54321",
      info: {
        first_name: "Greta",
        last_name: "Gnome",
        name: "Greta Gnome",
        email: "greta.gardengnome@example.com",
        social: "555443333",
        phone: "15553332222",
        birth_date: "1990-09-04",
        age: 800,
        location: "Passaic Park, New Jersey",
        street: "1234 Green St",
        city: "Passaic Park",
        state: "New Jersey",
        zip: "22233",
        group: "identity",
        subgroups: ["IAL2"],
        verified: true,
      },
      credentials: {
        token: "mock_token",
        secret: "mock_secret"
      }
    })
  end

  before do
    allow_any_instance_of(ZendeskIntakeService).to receive(:create_intake_ticket_requester).and_return(4321)
    allow_any_instance_of(ZendeskIntakeService).to receive(:create_intake_ticket).and_return(9876)
    # see note below about skipping redirects
    allow_any_instance_of(Users::SessionsController).to receive(:idme_logout).and_return(
      user_idme_omniauth_callback_path(spouse: "true")
    )
  end

  scenario "new client filing joint taxes with spouse and dependents" do
    visit "/questions/identity"
    expect(page).to have_selector("h1", text: "Sign in")
    click_on "Sign in with ID.me"

    # the ID.me flow would occur here. They should end up back on a success page.

    # Consent form
    expect(page).to have_selector("h1", text: "Great! Here's our terms of service.")
    check "I agree"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Welcome Gary!")
    click_on "Continue"

    # Personal Information
    expect(page).to have_text("What is your mailing address?")
    fill_in "Street address", with: "123 Main St."
    fill_in "City", with: "Anytown"
    select "California", from: "State"
    fill_in "ZIP code", with: "94612"
    click_on "Confirm"

    expect(page).to have_text("How may we contact you about your taxes?")
    check "Email Notifications"
    check "SMS Notifications"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Have you ever been legally married?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "As of December 31, 2019, were you legally married?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "Did you live with your spouse during any part of the last six months of 2019?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "Are you legally separated?")
    click_on "No"

    expect(page).to have_selector("h1", text: "As of December 31, 2019, were you divorced?")
    click_on "No"

    expect(page).to have_selector("h1", text: "As of December 31, 2019, were you widowed?")
    click_on "No"

    expect(page).to have_selector("h1", text: "Are you filing joint taxes with your spouse?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "Spouse Identity")

    OmniAuth.config.mock_auth[:idme] = spouse_auth_hash
    # The following click would trigger a series of redirects
    # To simplify this feature spec, we stub out the initial request
    # in order to skip to the final redirect. We skip from step 1 to step 4.
    # Full sequences of steps
    #   1. delete destroy_idme_session_path --> redirect to external Id.me signout
    #   2. get external ID.me signout --> redirect to omniauth_failure_path(logout: "primary")
    #   3. get omniauth_failure_path(logout: "primary") --> redirect to external Id.me authorize
    #   4. get external ID.me authorize --> user_idme_omniauth_callback_path(spouse: "true")
    click_on "Sign in spouse with ID.me"
    expect(page).to have_selector("h1", text: "Welcome Gary and Greta!")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Did you have any dependents in 2019?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "Let’s add your dependents!")
    click_on "Add a dependent"
    fill_in "First name", with: "Greg"
    fill_in "Last name", with: "Gnome"
    select "March", from: "Month"
    select "5", from: "Day"
    select "2003", from: "Year"
    fill_in "Relationship to you", with: "Son"
    select "6", from: "How many months did they live in your home during 2019?"
    check "Full-time student"
    click_on "Save dependent"
    expect(page).to have_text("Greg Gnome")

    click_on "Add a dependent"
    fill_in "First name", with: "Gallagher"
    fill_in "Last name", with: "Gnome"
    select "November", from: "Month"
    select "24", from: "Day"
    select "2005", from: "Year"
    fill_in "Relationship to you", with: "Nibling"
    select "2", from: "How many months did they live in your home during 2019?"
    check "In the US on a Visa"
    click_on "Save dependent"
    expect(page).to have_text("Gallagher Gnome")

    click_on "Done with this step"

    select "3 jobs", from: "In 2019, how many jobs did you have?"
    click_on "Next"

    expect(page).to have_selector("h1", text: "In 2019, did you receive wages or salary?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you receive any tips?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have any income from contract or self-employment work?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "Did you report a business loss on your 2018 tax return?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have any income from a retirement account, pension, or annuity proceeds?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have any income from Social Security or Railroad Retirement Benefits?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you receive any unemployment benefits?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you receive any disability benefits?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have any income from interest or dividends?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have any income from the sale of stocks, bonds, or real estate?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "Did you report a loss from the sale of stocks, bonds, or real estate on your 2018 return?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you receive any income from alimony?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have any income from rental properties?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have any income from farm activity?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have any income from gambling winnings, including the lottery?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you receive a state or local income tax refund?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you receive any other money?")
    click_on "Yes"

    fill_in "What were the other types of income that you received?", with: "cash from gardening"
    click_on "Next"

    expect(page).to have_selector("h1", text: "In 2019, did you pay any mortgage interest?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you pay any state, local, real estate, sales, or other taxes?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you pay any medical, dental, or prescription expenses?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you make any charitable contributions?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you pay any student loan interest?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you pay any child or dependent care expenses?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you make any contributions to a retirement account?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you pay for any eligible school supplies as a teacher, teacher's aide, or other educator?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you make any alimony payments?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, was someone in your family a college or other post high school student?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you sell a home?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have a Health Savings Account?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you purchase health insurance through the marketplace or exchange?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "Did you receive the First Time Homebuyer Credit in 2008?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have debt cancelled or forgiven by a lender?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have a loss related to a declared Federal Disaster Area?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you adopt a child?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "Have you had the Earned Income Credit, Child Tax Credit, American Opportunity Credit, or Head of Household filing status disallowed in a prior year?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you receive any letter or bill from the IRS?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you make any estimated tax payments or apply your 2018 refund to your 2019 taxes?")
    click_on "Yes"

    fill_in "Is there any additional information you think we should know?", with: "One of my kids moved away for college, should I include them as a dependent?"
    click_on "Next"

    expect(page).to have_selector("h1", text: "Attach a copy of your W-2’s")
    attach_file("w2s_form_document", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))
    click_on "Upload"

    expect(page).to have_content("test-pattern.png")
    expect(page).to have_link("Remove")

    attach_file("w2s_form_document", Rails.root.join("spec", "fixtures", "attachments", "picture_id.jpg"))
    click_on "Upload"

    expect(page).to have_content("test-pattern.png")
    expect(page).to have_content("picture_id.jpg")
    click_on "Done with this step"

    expect(page).to have_selector("h1", text: "Do you have any additional documents?")
    attach_file("additional_documents_form_document", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))
    click_on "Upload"
    expect(page).to have_content("test-pattern.png")
    click_on "Done with this step"

    expect(page).to have_selector("h1", text: "Great work! Here's a list of what we've collected.")
    click_on "I'm done"

    fill_in "Do you have any time preferences for your interview phone call?", with: "During school hours"

    click_on "Continue"
  end
end

