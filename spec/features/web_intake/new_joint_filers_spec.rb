require "rails_helper"

RSpec.feature "Web Intake Joint Filers", :flow_explorer_screenshot do
  include MockTwilio

  let!(:vita_partner) { create :organization, name: "Virginia Partner" }
  let!(:vita_partner_zip_code) { create :vita_partner_zip_code, zip_code: "20121", vita_partner: vita_partner }

  scenario "new client filing joint taxes with spouse and dependents", js: true, screenshot: true do
    answer_gyr_triage_questions(screenshot_method: self.method(:screenshot_after), choices: :defaults)

    screenshot_after do
      expect(page).to have_selector("h1", text: I18n.t('questions.triage_gyr.edit.title'))
      click_on I18n.t('questions.triage_gyr.edit.file_online')
    end

    screenshot_after do
      # Ask about backtaxes
      expect(page).to have_selector("h1", text: I18n.t("views.questions.backtaxes.title"))
      check "#{TaxReturn.current_tax_year - 3}"
      check "#{TaxReturn.current_tax_year}"
    end
    click_on "Continue"
    # creates intake
    intake = Intake.last

    # Non-production environment warning
    screenshot_after do
      expect(page).to have_selector("h1", text: "Thanks for visiting the GetYourRefund demo application!")
    end
    click_on "Continue to example"

    screenshot_after do
      expect(page).to have_selector("h1", text: "Let's get started")
    end
    click_on "Continue"

    screenshot_after do
      # Overview
      expect(page).to have_selector("h1", text: "Just a few simple steps to file!")
    end
    click_on "Continue"

    screenshot_after do
      # Personal Info
      expect(page).to have_selector("h1", text: "First, let's get some basic information.")
      fill_in I18n.t('views.questions.personal_info.preferred_name'), with: "Gary"
      fill_in "Phone number", with: "415-888-0088"
      fill_in "Confirm phone number", with: "415-888-0088"
      fill_in I18n.t("attributes.primary_ssn"), with: "123-45-6789"
      fill_in I18n.t("attributes.confirm_primary_ssn"), with: "123-45-6789"
      fill_in "ZIP code", with: "20121"
    end
    click_on "Continue"

    screenshot_after do
      # Interview time preferences
      fill_in "Do you have any time preferences for your interview phone call?", with: "During school hours"
    end
    click_on "Continue"

    screenshot_after do
      # Notification Preference
      expect(intake.reload.current_step).to eq("/en/questions/notification-preference")
      check "Email Me"
      check "Text Me"
      click_on "Continue"
    end

    screenshot_after do
      # Phone number can text
      expect(page).to have_text("Can we text the phone number you previously entered?")
      click_on "No"
    end

    screenshot_after do
      # Phone number
      expect(page).to have_selector("h1", text: "Please share your cell phone number.")
      fill_in "Cell phone number", with: "(415) 553-7865"
      fill_in "Confirm cell phone number", with: "+1415553-7865"
      click_on "Continue"
    end

    screenshot_after do
      # Verify cell phone contact
      expect(page).to have_selector("h1", text: "Let's verify that contact info with a code!")
      perform_enqueued_jobs
      sms = FakeTwilioClient.messages.last
      code = sms.body.to_s.match(/\s(\d{6})[.]/)[1]
      fill_in "Enter 6 digit code", with: code
      click_on "Verify"
    end

    screenshot_after do
      # Email
      expect(page).to have_selector("h1", text: "Please share your email address.")
      fill_in "Email address", with: "gary.gardengnome@example.green"
      fill_in "Confirm email address", with: "gary.gardengnome@example.green"
    end
    click_on "Continue"

    screenshot_after do
      # Verify email contact
      expect(page).to have_selector("h1", text: "Let's verify that contact info with a code!")
      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]
      fill_in "Enter 6 digit code", with: code
      click_on "Verify"
    end

    screenshot_after do
      # Consent form
      expect(page).to have_selector("h1", text: "Great! Here's the legal stuff...")
      fill_in "Legal first name", with: "Gary"
      fill_in "Legal last name", with: "Gnome"
      select "March", from: "Month"
      select "5", from: "Day"
      select "1971", from: "Year"
    end
    click_on "I agree"
    # create tax returns only after client has consented
    expect(intake.client.tax_returns.map(&:year)).to match_array [TaxReturn.current_tax_year - 3, TaxReturn.current_tax_year]
    expect(intake.reload.client.tax_returns.pluck(:status)).to eq ["intake_in_progress", "intake_in_progress"]

    screenshot_after do
      # Optional consent form
      expect(page).to have_selector("h1", text: "A few more things...")
    end
    click_on "Continue"

    screenshot_after do
      # Chat with us
      expect(page).to have_selector("h1", text: "Our team at Virginia Partner is here to help!")
    end
    click_on "Continue"

    screenshot_after do
      # Primary filer personal information
      expect(page).to have_selector("h1", text: "Select any situations that were true for you in #{TaxReturn.current_tax_year}")
      check "I had a permanent disability"
      check "I was legally blind"
      check "I was a full-time student in a college or a trade school"
      check "I was in the US on a Visa"
    end
    click_on "Continue"

    screenshot_after do
      expect(page).to have_selector("h1", text: I18n.t("views.questions.arp_payments.title"))
    end
    fill_in "Stimulus 1", with: 800
    fill_in 'Stimulus 2', with: 1000
    fill_in 'Stimulus 3', with: 1000
    check "I am unsure of my Advanced Child Tax Credit amount"
    click_on "Continue"

    screenshot_after do
      expect(page).to have_selector("h1", text: "Have you ever been issued an IP PIN because of identity theft?")
    end
    click_on "No"


    # Marital status
    screenshot_after do
      expect(page).to have_selector("h1", text: "Have you ever been legally married?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "As of December 31, #{TaxReturn.current_tax_year}, were you legally married?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "Did you live with your spouse during any part of the last six months of #{TaxReturn.current_tax_year}?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "Are you legally separated?")
    end
    click_on "Yes"
    click_on "Go back"
    click_on "No"
    screenshot_after do
      expect(page).to have_selector("h1", text: "As of December 31, #{TaxReturn.current_tax_year}, were you divorced?")
    end
    click_on "Yes"
    click_on "Go back"
    click_on "No"
    screenshot_after do
      expect(page).to have_selector("h1", text: "As of December 31, #{TaxReturn.current_tax_year}, were you widowed?")
    end
    click_on "Yes"
    click_on "Go back"
    click_on "No"

    screenshot_after do
      # Filing status
      expect(page).to have_selector("h1", text: "Are you filing joint taxes with your spouse?")
    end
    click_on "Yes"

    # Alimony
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse receive any income from alimony?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse make any alimony payments?")
    end
    click_on "Yes"

    # Spouse email
    screenshot_after do
      expect(page).to have_selector("h1", text: "Please share your spouse's e-mail address")
      fill_in "E-mail address", with: "greta.gardengnome@example.green"
      fill_in "Confirm e-mail address", with: "greta.gardengnome@example.green"
    end
    click_on "Continue"

    screenshot_after do
      # Spouse consent
      expect(page).to have_selector("h1", text: "We need your spouse to review our legal stuff...")
      fill_in "Spouse's legal first name", with: "Greta"
      fill_in "Spouse's legal last name", with: "Gnome"
      fill_in I18n.t("attributes.spouse_ssn"), with: "123-45-6789"
      fill_in I18n.t("attributes.confirm_spouse_ssn"), with: "123-45-6789"
      select "March", from: "Month"
      select "5", from: "Day"
      select "1971", from: "Year"
    end
    click_on "I agree"

    # Spouse personal information
    screenshot_after do
      expect(page).to have_selector("h1", text: "Select any situations that were true for your spouse in #{TaxReturn.current_tax_year}")
      check "None of the above"
    end
    click_on "Continue"
    screenshot_after do
      expect(page).to have_selector("h1", text: "Has your spouse been issued an Identity Protection PIN?")
    end
    click_on "No"

    # Dependents
    screenshot_after do
      expect(page).to have_selector("h1", text: "Would you or your spouse like to claim anyone for #{TaxReturn.current_tax_year}?")
    end
    click_on "Yes"

    screenshot_after do
      expect(page).to have_selector("h1", text: "Let’s claim someone!")
      expect(track_progress).to be_present
      click_on "Add a person"
      fill_in "First name", with: "Greg"
      fill_in "Last name", with: "Gnome"
      select "March", from: "Month"
      select "5", from: "Day"
      select "2003", from: "Year"
      fill_in "Relationship to you", with: "Son"
      select "6", from: "How many months did they live in your home in #{TaxReturn.current_tax_year}?"
      check "Full time higher education student"
      click_on "Save this person"
      expect(page).to have_text("Greg Gnome")

      click_on "Add a person"
      fill_in "First name", with: "Gallagher"
      fill_in "Last name", with: "Gnome"
      select "November", from: "Month"
      select "24", from: "Day"
      select "2005", from: "Year"
      fill_in "Relationship to you", with: "Nibling"
      select "2", from: "How many months did they live in your home in #{TaxReturn.current_tax_year}?"
      check "Is this person here on a VISA?"
      check "Married as of 12/31/#{TaxReturn.current_tax_year}"
      click_on "Save this person"
      expect(page).to have_text("Gallagher Gnome")
    end
    click_on "Done with this step"

    # Dependent related questions
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse pay any child or dependent care expenses?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse adopt a child?")
    end
    click_on "Yes"

    # Student questions
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, was someone in your family a college or other post high school student?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse pay any student loan interest?")
    end
    click_on "Yes"

    # Income from working
    screenshot_after do
      select "3 jobs", from: "In #{TaxReturn.current_tax_year}, how many jobs did you or your spouse have?"
    end
    click_on "Next"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you live or work in any other states besides Virginia?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "Tell us about you and your spouse's work in #{TaxReturn.current_tax_year}")
      check "My spouse or I worked for someone else"
      check "My spouse or I was self-employed or worked as an independent contractor"
      check "My spouse or I collected tips at work not included in a W-2"
      check "My spouse or I received unemployment benefits"
    end
    click_on "Continue"

    # Income from benefits
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse receive any disability benefits?")
    end
    click_on "Yes"

    # Investment income/loss
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse have any income from interest or dividends?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse sell any stocks, bonds, or real estate?")
    end
    click_on "No"

    # Retirement income/contributions
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse have Social Security income, retirement income, or retirement contributions?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse have any income from Social Security or Railroad Retirement Benefits?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse have any income from a retirement account, pension, or annuity proceeds?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: I18n.t("views.questions.retirement_contributions.title.other", year: TaxReturn.current_tax_year))
    end
    click_on "Yes"

    # Other income
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse receive any other money?")
    end
    click_on "Yes"
    screenshot_after do
      fill_in "What were the other types of income that you or your spouse received?", with: "cash from gardening"
    end
    click_on "Next"

    # Health insurance
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse purchase health insurance through the marketplace or exchange?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse have a Health Savings Account?")
    end
    click_on "Yes"

    # Itemizing
    screenshot_after do
      expect(page).to have_selector("h1", text: "Would you like to itemize your deductions for #{TaxReturn.current_tax_year}?")
    end
    click_on "I don't know"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse pay any medical, dental, or prescription expenses?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse make any charitable contributions?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse have any income from gambling winnings, including the lottery?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse pay for any eligible school supplies as a teacher, teacher's aide, or other educator?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse pay any state, local, real estate, sales, or other taxes?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse receive a state or local income tax refund?")
    end
    click_on "Yes"

    # Related to home ownership
    screenshot_after do
      expect(page).to have_selector("h1", text: "Have you or your spouse ever owned a home?")
    end
    click_on "No"

    # Miscellaneous
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse have a loss related to a declared Federal Disaster Area?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse have debt cancelled or forgiven by a lender?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse receive any letter or bill from the IRS?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "Have you or your spouse had the Earned Income Credit, Child Tax Credit, American Opportunity Credit, or Head of Household filing status disallowed in a prior year?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse make any estimated tax payments or apply your #{TaxReturn.current_tax_year - 1} refund to your #{TaxReturn.current_tax_year} taxes?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "Did you or your spouse report a business loss on your #{TaxReturn.current_tax_year - 1} tax return?")
    end
    click_on "Yes"
    screenshot_after do
      expect(page).to have_selector("h1", text: "In #{TaxReturn.current_tax_year}, did you or your spouse purchase energy efficient home items?")
    end
    click_on "Yes"

    screenshot_after do
      # Payment info
      expect(page).to have_selector("h1", text: "If due a refund, how would like to receive it?")
      choose "Mail me a check (slower)"
    end
    click_on "Continue"

    screenshot_after do
      expect(page).to have_selector("h1", text: "If due a refund, are you interested in using these savings options?")
    end
    click_on "Continue"

    screenshot_after do
      expect(page).to have_selector("h1", text: "If you have a balance due, would you like to make a payment directly from your bank account?")
    end
    click_on "No"
    # Don't ask for bank details

    screenshot_after do
      # Contact information
      expect(page).to have_text("What is your mailing address?")
      expect(page).to have_select('State', selected: 'Virginia')

      fill_in "Street address", with: "123 Main St."
      fill_in "City", with: "Anytown"
      select "California", from: "State"
      fill_in "ZIP code", with: "94612"
    end
    click_on "Confirm"

    screenshot_after do
      # Overview: Documents
      expect(page).to have_selector("h1", text: "Collect all your documents and have them with you.")
    end
    click_on "Continue"

    screenshot_after do
      # IRS guidance
      expect(page).to have_selector("h1", text: "First, we need to confirm your basic information.")
    end
    click_on "Continue"

    screenshot_after do
      expect(page).to have_selector("h1", text: "Attach photos of ID cards")
      upload_file("document_type_upload_form[document]", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))
      upload_file("document_type_upload_form[document]", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))
    end
    click_on "Continue"

    screenshot_after do
      expect(page).to have_selector("h1", text: "Confirm your identity with a photo of yourself")
    end
    click_on I18n.t('views.documents.selfie_instructions.submit_photo')

    screenshot_after do
      expect(page).to have_selector("h1", text: I18n.t('views.documents.selfies.title'))
      upload_file("document_type_upload_form[document]", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))
    end
    click_on "Continue"

    screenshot_after do
      expect(page).to have_selector("h1", text: I18n.t('views.documents.ssn_itins.title'))
      upload_file("document_type_upload_form[document]", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))
    end
    click_on "Continue"

    screenshot_after do
      # Documents: Intro
      expect(page).to have_selector("h1", text: I18n.t('views.documents.intro.title'))
    end
    click_on "Continue"

    screenshot_after do
      expect(page).to have_selector("h1", text: I18n.t('views.documents.form1095as.title'))
      upload_file("document_type_upload_form[document]", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))
    end
    click_on "Continue"

    screenshot_after do
      expect(page).to have_selector("h1", text: "Share your employment documents")
      upload_file("document_type_upload_form[document]", Rails.root.join("spec", "fixtures", "files", "test-pattern.png"))

      expect(page).to have_content("test-pattern.png")
      expect(page).to have_link("Remove")

      upload_file("document_type_upload_form[document]", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))

      expect(page).to have_content("test-pattern.png")
      expect(page).to have_content("picture_id.jpg")
    end
    click_on "Continue"

    screenshot_after do
      expect(page).to have_selector("h1", text: "Attach your 1099-R's")
      upload_file("document_type_upload_form[document]", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))
    end
    expect do
      click_on "Continue"
    end.to change { intake.client.tax_returns.pluck(:status) }.from(["intake_in_progress", "intake_in_progress"]).to(["intake_ready", "intake_ready"])

    screenshot_after do
      expect(page).to have_selector("h1", text: "Please share any additional documents.")
      upload_file("document_type_upload_form[document]", Rails.root.join("spec", "fixtures", "files", "test-pattern.png"))
      expect(page).to have_content("test-pattern.png")
    end
    click_on "Continue"

    screenshot_after do
      expect(page).to have_selector("h1", text: "Great work! Here's a list of what we've collected.")
      expect { track_progress }.to change { @current_progress }
    end
    click_on "I've shared all my documents"

    screenshot_after do
      # Final Information
      fill_in "Anything else you'd like your tax preparer to know about your situation?", with: "One of my kids moved away for college, should I include them as a dependent?"
    end
    click_on "Submit"

    screenshot_after do
      expect(page).to have_selector("h1", text: "Success! Your tax information has been submitted.")
      expect(page).to have_text("Your confirmation number is: #{intake.client_id}")
    end
    click_on "Great!"

    expect(intake.reload.current_step).to eq("/en/questions/feedback")
    fill_in "Thank you for sharing your experience.", with: "I am a joint filer. I file with my spouse."
    click_on "Continue"

    # Demographic Questions
    screenshot_after do
      expect(page).to have_selector("h1", text: "Are you willing to answer some additional questions to help us better serve you?")
    end
    click_on "Continue"
    screenshot_after do
      expect(page).to have_text("How well would you say you can carry on a conversation in English?")
      choose "Well"
    end
    click_on "Continue"
    screenshot_after do
      expect(page).to have_text("How well would you say you read a newspaper in English?")
      choose "Not well"
    end
    click_on "Continue"
    screenshot_after do
      expect(page).to have_text("Do you or any member of your household have a disability?")
      choose "No"
    end
    click_on "Continue"
    screenshot_after do
      expect(page).to have_text("Are you or your spouse a veteran of the U.S. Armed Forces?")
      choose "Yes"
    end
    click_on "Continue"
    screenshot_after do
      expect(page).to have_selector("h1", text: "What is your race?")
      check "White"
    end
    click_on "Continue"
    screenshot_after do
      expect(page).to have_selector("h1", text: "What is your spouse's race?")
      check "White"
    end
    click_on "Continue"
    screenshot_after do
      expect(page).to have_text("What is your ethnicity?")
      choose "Not Hispanic or Latino"
    end
    click_on "Continue"
    screenshot_after do
      expect(page).to have_text("What is your spouse's ethnicity?")
      choose "Not Hispanic or Latino"
    end
    click_on "Continue"
  end
end

