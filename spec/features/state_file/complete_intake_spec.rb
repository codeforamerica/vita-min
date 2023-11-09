require "rails_helper"

RSpec.feature "Completing a state file intake", active_job: true do
  include MockTwilio
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  context "NY", :flow_explorer_screenshot do
    it "has content" do
      visit "/"
      click_on "Start Test NY"

      expect(page).to have_text "File your New York state taxes for free"
      click_on "Get Started", id: "firstCta"

      step_through_initial_authentication(contact_preference: :text_message)

      step_through_df_data_transfer

      expect(page).to have_text "The page with all the info from the 1040"

      expect(page).to have_field("tax return year", with: "2023")
      click_on "Populate with sample data"
      click_on "Continue"

      expect(page).to have_text "The page that shows your dependents"
      expect(page).to have_text "TESSA TESTERSON"
      click_on "Continue"

      expect(page).to have_text I18n.t('state_file.questions.dob.edit.title2_you_and_household')
      select_cfa_date "state_file_dob_form_primary_birth_date", Date.new(1978, 6, 21)
      expect(page).to have_text "Date of birth for Tessa"
      select_cfa_date "state_file_dob_form_dependents_attributes_0_dob", Date.new(2017, 7, 12)
      click_on "Continue"

      expect(page).to have_text "Was this your permanent home address on December 31, 2023?"
      choose "Yes"
      click_on "Continue"
      click_on "Go back"

      expect(page).to have_text "Was this your permanent home address on December 31, 2023?"
      choose "No"
      # if they previously confirmed their address from DF, don't show it filled in on the form for a new permanent address
      expect(find_field("state_file_ny_permanent_address_form[permanent_street]").value).to eq ""
      fill_in "Street Address", with: "321 Peanut Way"
      fill_in "Apartment/Unit Number", with: "B"
      fill_in "City", with: "New York"
      fill_in "Zip code", with: "11102"
      click_on "Continue"

      expect(page).to have_text "Select the county where you lived on December 31, 2023"
      select("Nassau", from: "County")
      click_on "Continue"

      expect(page).to have_text "Select the school district where you lived on December 31, 2023"
      select("Bellmore-Merrick CHS Bellmore", from: "School District Name")
      click_on "Continue"

      expect(page).to have_text I18n.t('state_file.questions.ny_sales_use_tax.edit.title', year: MultiTenantService.statefile.current_tax_year)
      choose I18n.t("general.negative")
      click_on I18n.t("general.continue")

      expect(page).to have_text "The page with all the info from the 201"
      click_on "Continue"

      expect(page).to have_text "The page with all the info from the IT-214"
      click_on "Continue"

      expect(page).to have_text I18n.t('state_file.questions.unemployment.edit.title')
      choose "Yes"
      choose "NYS Department of Labor"
      # TODO: test 'Myself'/'Spouse' radio for married filing jointly situation
      choose I18n.t('state_file.questions.unemployment.edit.confirm_address_yes')
      fill_in I18n.t('state_file.questions.unemployment.edit.unemployment_compensation'), with: "123"
      fill_in I18n.t('state_file.questions.unemployment.edit.federal_income_tax_withheld'), with: "456"
      fill_in I18n.t('state_file.questions.unemployment.edit.state_income_tax_withheld'), with: "789"
      click_on "Continue"

      expect(page).to have_text(I18n.t('state_file.questions.unemployment.index.1099_label', name: StateFileNyIntake.last.primary.full_name))
      click_on "Continue"

      click_on "Submit My Fake Taxes"

      expect(page).to have_text "You have successfully submitted your taxes"
      expect(page).to have_link "Download PDF"
      click_on "Show XML"
      expect(page.body).to include('efile:ReturnState')
      expect(page.body).to include('<ABA_NMBR claimed="013456789"/>')
      expect(page.body).to include('<BANK_ACCT_NMBR claimed="456789008765"/>')

      perform_enqueued_jobs
      submission = EfileSubmission.last
      # Asserting on metadata so we can get a good error if bundling starts to fail
      # (the metadata will include error_code and raw_response)
      expect(submission.last_transition.metadata).to eq({})
      expect(submission.submission_bundle).to be_present
      expect(submission.current_state).to eq("queued")
    end
  end

  context "AZ", :flow_explorer_screenshot do
    it "has content" do
      visit "/"
      click_on "Start Test AZ"

      expect(page).to have_text "File your Arizona state taxes for free"
      click_on "Get Started", id: "firstCta"

      step_through_initial_authentication(contact_preference: :email)

      step_through_df_data_transfer

      click_on "Populate with sample data"
      click_on "Continue"

      expect(page).to have_text "The page that shows your dependents"
      expect(page).to have_text "TESSA TESTERSON"
      click_on "Add a person"

      expect(page).to have_text "Tell us about your dependent."
      fill_in "First name", with: "Grampy"
      fill_in "Last name", with: "Gramps"
      fill_in "ssn", with: "123-45-6789"
      select "GRANDPARENT", from: "Relationship to you"
      select_cfa_date "state_file_dependent_dob", Date.new(1950, 10, 31)
      click_on "Save this person"

      expect(page).to have_text "The page that shows your dependents"
      expect(page).to have_text "Grampy Gramps 10/31/1950"
      click_on "Continue"

      expect(page).to have_text "First, please provide more information about the people in your family."
      expect(page).to have_text "Date of birth for Tessa"
      select_cfa_date "state_file_dob_form_dependents_attributes_0_dob", Date.new(2017, 7, 12)
      select "12", from: "state_file_dob_form_dependents_attributes_0_months_in_home"
      click_on "Continue"

      expect(page).to have_text "Please provide some more information about the people in your family who are 65 years of age or older."
      expect(page).to have_text "Did Grampy need assistance with daily living activities"
      expect(page).to have_text "Did Grampy pass away"
      choose "state_file_az_senior_dependents_form_dependents_attributes_0_needed_assistance_yes"
      choose "state_file_az_senior_dependents_form_dependents_attributes_0_passed_away_no"
      click_on "Continue"

      expect(page).to have_text "Did you file with a different last name in the last four years?"
      choose "state_file_az_prior_last_names_form_has_prior_last_names_yes"
      fill_in "state_file_az_prior_last_names_form_prior_last_names", with: "Jordan, Pippen, Rodman"
      click_on "Continue"

      expect(page).to have_text I18n.t('state_file.questions.unemployment.edit.title')
      choose "Yes"
      choose "AZ Department of Economic Security"
      # TODO: test 'Myself'/'Spouse' radio for married filing jointly situation
      choose I18n.t('state_file.questions.unemployment.edit.confirm_address_yes')
      fill_in I18n.t('state_file.questions.unemployment.edit.unemployment_compensation'), with: "123"
      fill_in I18n.t('state_file.questions.unemployment.edit.federal_income_tax_withheld'), with: "456"
      fill_in I18n.t('state_file.questions.unemployment.edit.state_income_tax_withheld'), with: "789"
      click_on "Continue"

      expect(page).to have_text(I18n.t('state_file.questions.unemployment.index.1099_label', name: StateFileAzIntake.last.primary.full_name))
      click_on "Continue"

      expect(page).to have_text("Do any of the following scenarios apply to you? (Less common)")
      check "state_file_az_state_credits_form_tribal_member"
      fill_in "state_file_az_state_credits_form_tribal_wages", with: "100"
      check "state_file_az_state_credits_form_armed_forces_member"
      fill_in "state_file_az_state_credits_form_armed_forces_wages", with: "100"
      click_on "Continue"

      expect(page).to have_text "Did you make charitable contributions to a qualifying organization in 2023?"
      choose "Yes"
      fill_in "Enter the total amount of cash or check contributions made in 2023. (Note: you may be asked to provide receipts for donations over $250.)", with: "123"
      fill_in "Enter the total amount of non-cash contributions made in 2023 (example: the fair market value of donated items). This cannot exceed $500.", with: "123"
      click_on "Continue"

      expect(page).to have_text("You're done! Let's review before you submit your state tax return.")
      click_on "Continue"

      click_on "Submit My Fake Taxes"

      expect(page).to have_text "You have successfully submitted your taxes"
      click_on "Show XML"

      expect(page.body).to include('efile:ReturnState')
      expect(page.body).to include('<FirstName>Testy</FirstName>')
      expect(page.body).to include('<QualParentsAncestors>')
      expect(page.body).to include('<WageAmIndian>100</WageAmIndian>')
      expect(page.body).to include('<CompNtnlGrdArmdFrcs>100</CompNtnlGrdArmdFrcs>')

      perform_enqueued_jobs
      submission = EfileSubmission.last
      expect(submission.submission_bundle).to be_present
      expect(submission.current_state).to eq("queued")
    end
  end
end
