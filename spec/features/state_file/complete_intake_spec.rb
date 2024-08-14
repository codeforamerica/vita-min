require "rails_helper"

RSpec.feature "Completing a state file intake", active_job: true do
  include MockTwilio
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  context "NY", :flow_explorer_screenshot, js: true do
    it "has content" do
      visit "/"
      click_on "Start Test NY"

      expect(page).to have_text I18n.t("state_file.landing_page.edit.ny.title")
      click_on I18n.t('general.get_started'), id: "firstCta"

      step_through_eligibility_screener(us_state: "ny")

      step_through_initial_authentication(contact_preference: :email)

      expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
      click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

      step_through_df_data_transfer

      expect(page).to have_text I18n.t("state_file.questions.data_review.edit.title")
      click_on I18n.t("general.continue")

      # name dob page
      expect(page).to have_text I18n.t("state_file.questions.name_dob.edit.title1")
      expect(page).to have_text I18n.t("state_file.questions.name_dob.edit.title2")
      expect(page).to have_text "Your responses are saved. If you need a break, you can come back and log in to your account at fileyourstatetaxes.org."
      fill_in "state_file_name_dob_form[primary_first_name]", with: "Titus"
      fill_in "state_file_name_dob_form[primary_last_name]", with: "Testerson"
      select_cfa_date "state_file_name_dob_form_primary_birth_date", Date.new(1978, 6, 21)

      within "#dependent-0" do
        expect(page).to have_text I18n.t("state_file.questions.name_dob.edit.dependent_name_dob", number: "first")
        expect(page).to have_field("state_file_name_dob_form_dependents_attributes_0_first_name", disabled: true)
        expect(page).to have_field("state_file_name_dob_form_dependents_attributes_0_last_name", disabled: true)

        select_cfa_date "state_file_name_dob_form_dependents_attributes_0_dob", Date.new(2017, 7, 12)
      end
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.nyc_residency.edit.title", year: 2023)
      choose "I did not live in New York City at all in 2023"
      choose I18n.t("general.affirmative")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.eligibility_offboarding.edit.ineligible_reason.nyc_maintained_home")
      click_on "Go back"
      expect(page).to have_text I18n.t("state_file.questions.nyc_residency.edit.title", year: 2023)
      choose "I lived in New York City all year in 2023"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.ny_county.edit.title", filing_year: MultiTenantService.statefile.current_tax_year)
      select("Nassau", from: "County")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.ny_school_district.edit.title", filing_year: MultiTenantService.statefile.current_tax_year)
      select("Bellmore-Merrick CHS Bellmore", from: "School District Name")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.ny_permanent_address.edit.title")
      choose I18n.t("general.affirmative")
      click_on I18n.t("general.continue")
      click_on "Go back"

      expect(page).to have_text I18n.t("state_file.questions.ny_permanent_address.edit.title")
      choose I18n.t("general.negative")
      # if they previously confirmed their address from DF, don't show it filled in on the form for a new permanent address
      expect(find_field("state_file_ny_permanent_address_form[permanent_street]").value).to eq ""
      fill_in I18n.t("state_file.questions.ny_permanent_address.edit.street_address_label"), with: "321 Peanut Way"
      fill_in I18n.t("state_file.questions.ny_permanent_address.edit.apartment_number_label"), with: "B"
      fill_in I18n.t("state_file.questions.ny_permanent_address.edit.city_label"), with: "New York"
      fill_in I18n.t("state_file.questions.ny_permanent_address.edit.zip_label"), with: "11102"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.ny_sales_use_tax.edit.title.one', year: MultiTenantService.statefile.current_tax_year)
      choose I18n.t("general.negative")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.primary_state_id.edit.title')
      choose I18n.t('state_file.questions.primary_state_id.state_id.id_type_question.dmv')
      fill_in I18n.t('state_file.questions.primary_state_id.state_id.id_details.number'), with: "012345678"
      select_cfa_date "state_file_ny_primary_state_id_form_issue_date", 4.years.ago.beginning_of_year
      select_cfa_date "state_file_ny_primary_state_id_form_expiration_date", 4.years.from_now.beginning_of_year
      select("New York", from: I18n.t('state_file.questions.primary_state_id.state_id.id_details.issue_state'))
      fill_in "For New York IDs: First three characters of the document number (located on the back of your ID)", with: "ABC"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.unemployment.edit.title.one', year: MultiTenantService.statefile.current_tax_year)
      choose I18n.t("general.affirmative")
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_name'), with: "Business Name"
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_address'), with: "123 Main St"
      fill_in I18n.t('state_file.questions.unemployment.edit.city'), with: "New York", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.zip_code'), with: "11102", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_tin'), with: "270293117"
      choose I18n.t('state_file.questions.unemployment.edit.confirm_address_yes')
      fill_in 'state_file1099_g_unemployment_compensation', with: "123"
      fill_in 'state_file1099_g_federal_income_tax_withheld', with: "456"
      fill_in 'state_file1099_g_state_identification_number', with: "123456789"
      fill_in 'state_file1099_g_state_income_tax_withheld', with: "789"
      click_on I18n.t("general.continue")

      expect(page).to have_text(I18n.t('state_file.questions.unemployment.index.1099_label', name: StateFileNyIntake.last.primary.full_name))
      click_on I18n.t("general.continue")

      # From the review page, the user can go back to certain screens to edit and then should return directly to the
      # review page. This is well-covered by unit tests, but let's test just one of those screens here
      expect(page).to have_text I18n.t("state_file.questions.shared.review_header.title")
      within "#county" do
        click_on I18n.t("general.edit")
      end
      expect(page).to have_text I18n.t("state_file.questions.ny_county.edit.title", filing_year: MultiTenantService.statefile.current_tax_year)
      click_on I18n.t("general.continue")
      expect(page).to have_text I18n.t("state_file.questions.ny_school_district.edit.title", filing_year: MultiTenantService.statefile.current_tax_year)
      click_on I18n.t("general.continue")
      expect(page).to have_text I18n.t("state_file.questions.shared.review_header.title")
      click_on I18n.t("general.continue")

      expect(page).to have_text "Good news, you're getting a New York State tax refund of $1468. How would you like to receive your refund?"
      expect(page).to_not have_text "Your responses are saved. If you need a break, you can come back and log in to your account at fileyourstatetaxes.org."
      choose I18n.t("state_file.questions.tax_refund.edit.mail")
      click_on I18n.t("general.continue")

      expect(page).to have_text(I18n.t('state_file.questions.esign_declaration.edit.title', state_name: "New York"))
      expect(page).to have_text("I have examined the information on my NYS electronic tax return, including all information transferred to my NYS return from my federal return")
      check "state_file_esign_declaration_form_primary_esigned"
      click_on I18n.t('state_file.questions.esign_declaration.edit.submit')

      expect(page).to have_text I18n.t("state_file.questions.submission_confirmation.edit.title", state_name: "New York")
      expect(page).to have_link I18n.t("state_file.questions.submission_confirmation.edit.download_state_return_pdf")
      click_on "Main XML Doc"
      expect(page.body).to include('ReturnState')
      expect(page.body).to include('<FirstName>Titus</FirstName>')

      assert_flow_explorer_sample_params_includes_everything('ny')

      perform_enqueued_jobs
      submission = EfileSubmission.last
      # Asserting on metadata so we can get a good error if bundling starts to fail
      # (the metadata will include error_code and raw_response)
      expect(submission.last_transition.metadata).to eq({})
      expect(submission.submission_bundle).to be_present
      expect(submission.current_state).to eq("queued")
    end
  end

  context "AZ", :flow_explorer_screenshot, js: true do
    it "has content" do
      visit "/"
      click_on "Start Test AZ"

      expect(page).to have_text I18n.t("state_file.landing_page.edit.az.title")
      click_on I18n.t('general.get_started'), id: "firstCta"

      step_through_eligibility_screener(us_state: "az")

      step_through_initial_authentication(contact_preference: :email)

      expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
      click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

      step_through_df_data_transfer("Transfer Old sample")

      expect(page).to have_text I18n.t("state_file.questions.data_review.edit.title")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.name_dob.edit.title1")
      expect(page).to have_text I18n.t("state_file.questions.name_dob.edit.title2")
      expect(page).to have_text "Your responses are saved. If you need a break, you can come back and log in to your account at fileyourstatetaxes.org."
      fill_in "state_file_name_dob_form_primary_first_name", with: "Titus"
      fill_in "state_file_name_dob_form_primary_last_name", with: "Testerson"
      select_cfa_date "state_file_name_dob_form_primary_birth_date", Date.new(1978, 6, 21)

      within "#dependent-0" do
        expect(page).to have_text I18n.t("state_file.questions.name_dob.edit.dependent_name_dob", number: "first")
        expect(page).to have_field("state_file_name_dob_form_dependents_attributes_0_first_name", disabled: true)
        expect(page).to have_field("state_file_name_dob_form_dependents_attributes_0_last_name", disabled: true)

        select_cfa_date "state_file_name_dob_form_dependents_attributes_0_dob", Date.new(2017, 7, 12)
        select "12", from: "state_file_name_dob_form_dependents_attributes_0_months_in_home"
      end
      within "#dependent-1" do
        select_cfa_date "state_file_name_dob_form_dependents_attributes_1_dob", Date.new(1940, 10, 31)
        select "12", from: "state_file_name_dob_form_dependents_attributes_1_months_in_home"
      end
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.az_senior_dependents.edit.title")
      expect(page).to have_text I18n.t("state_file.questions.az_senior_dependents.edit.assistance_label", name: "Grampy")
      expect(page).to have_text I18n.t("state_file.questions.az_senior_dependents.edit.passed_away_label", name: "Grampy")
      choose "state_file_az_senior_dependents_form_dependents_attributes_0_needed_assistance_yes"
      choose "state_file_az_senior_dependents_form_dependents_attributes_0_passed_away_no"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.az_prior_last_names.edit.title.one")
      choose "state_file_az_prior_last_names_form_has_prior_last_names_yes"
      fill_in "state_file_az_prior_last_names_form_prior_last_names", with: "Jordan, Pippen, Rodman"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.unemployment.edit.title.one', year: MultiTenantService.statefile.current_tax_year)
      choose I18n.t("general.affirmative")
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_name'), with: "Business Name"
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_address'), with: "123 Main St"
      fill_in I18n.t('state_file.questions.unemployment.edit.city'), with: "Phoenix", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.zip_code'), with: "85001", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_tin'), with: "123456789"
      choose I18n.t('state_file.questions.unemployment.edit.confirm_address_yes')
      fill_in 'state_file1099_g_unemployment_compensation', with: "123"
      fill_in 'state_file1099_g_federal_income_tax_withheld', with: "456"
      fill_in 'state_file1099_g_state_identification_number', with: "123456789"
      fill_in 'state_file1099_g_state_income_tax_withheld', with: "789"
      click_on I18n.t("general.continue")

      expect(page).to have_text(I18n.t('state_file.questions.unemployment.index.1099_label', name: StateFileAzIntake.last.primary.full_name))
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.az_subtractions.edit.title.one", year: MultiTenantService.statefile.current_tax_year)
      check "state_file_az_subtractions_form_tribal_member"
      fill_in "state_file_az_subtractions_form_tribal_wages", with: "100"
      check "state_file_az_subtractions_form_armed_forces_member"
      fill_in "state_file_az_subtractions_form_armed_forces_wages", with: "100"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.az_charitable_contributions.edit.title.one", tax_year: MultiTenantService.statefile.current_tax_year)
      choose I18n.t("general.affirmative")
      fill_in "Enter the total amount of cash contributions made in #{MultiTenantService.statefile.current_tax_year}. (Round to the nearest whole number. Note: you may be asked to provide receipts for donations over $250.)", with: "123"
      fill_in "Enter the total amount of non-cash contributions made in #{MultiTenantService.statefile.current_tax_year} (example: the fair market value of donated items). This cannot exceed $500 (round to the nearest whole number.)", with: "123"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.az_public_school_contributions.edit.title', year: MultiTenantService.statefile.current_tax_year)
      choose I18n.t("general.affirmative")
      fill_in "az322_contribution_school_name", with: "Tax Elementary"
      fill_in "az322_contribution_ctds_code", with: "123456789"
      fill_in "az322_contribution_district_name", with: "Testerson"
      fill_in "az322_contribution_amount", with: "200"
      select_cfa_date "az322_contribution_date_of_contribution", Date.new(2023, 6, 21)
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.az_public_school_contributions.index.lets_review')
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.az_qualifying_organization_contributions.form.main_heading', filing_year: Rails.configuration.statefile_current_tax_year)
      choose I18n.t("general.affirmative")
      fill_in "az321_contribution_charity_name", with: "Center for Ants"
      fill_in "az321_contribution_charity_code", with: "123456789"
      fill_in "az321_contribution_amount", with: "90"
      select_cfa_date "az321_contribution_date_of_contribution", Date.new(Rails.configuration.statefile_current_tax_year, 6, 21)

      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.az_qualifying_organization_contributions.index.lets_review')

      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.primary_state_id.edit.title')
      choose I18n.t('state_file.questions.primary_state_id.state_id.id_type_question.dmv')
      fill_in I18n.t('state_file.questions.primary_state_id.state_id.id_details.number'), with: "012345678"
      select_cfa_date "state_file_az_primary_state_id_form_issue_date", 4.years.ago.beginning_of_year
      select_cfa_date "state_file_az_primary_state_id_form_expiration_date", 4.years.from_now.beginning_of_year
      select("Arizona", from: I18n.t('state_file.questions.primary_state_id.state_id.id_details.issue_state'))
      click_on I18n.t("general.continue")

      # From the review page, the user can go back to certain screens to edit and then should return directly to the
      # review page. This is well-covered by unit tests, but let's test just one of those screens here
      expect(page).to have_text I18n.t("state_file.questions.shared.review_header.title")
      within "#prior-last-names" do
        click_on I18n.t("general.edit")
      end
      expect(page).to have_text I18n.t("state_file.questions.az_prior_last_names.edit.title.one")
      click_on I18n.t("general.continue")
      expect(page).to have_text I18n.t("state_file.questions.shared.review_header.title")
      click_on I18n.t("general.continue")

      expect(page).to have_text "Good news, you're getting a Arizona state tax refund of $1239. How would you like to receive your refund?"
      expect(page).to_not have_text "Your responses are saved. If you need a break, you can come back and log in to your account at fileyourstatetaxes.org."

      choose I18n.t("state_file.questions.tax_refund.edit.direct_deposit")
      expect(page).to have_text I18n.t("state_file.questions.tax_refund.bank_details.bank_title")
      fill_in "state_file_tax_refund_form_bank_name", with: "bank name"
      choose "Checking"
      fill_in "state_file_tax_refund_form_routing_number", with: "019456124"
      fill_in "state_file_tax_refund_form_routing_number_confirmation", with: "019456124"
      fill_in "state_file_tax_refund_form_account_number", with: "2222222222"
      fill_in "state_file_tax_refund_form_account_number_confirmation", with: "2222222222"
      click_on I18n.t("general.continue")

      expect(page).to have_text(I18n.t('state_file.questions.esign_declaration.edit.title', state_name: "Arizona"))
      expect(page).to have_text("Under penalties of perjury, I declare that I have examined a copy of my electronic Arizona individual income tax return")
      check "state_file_esign_declaration_form_primary_esigned"
      click_on I18n.t('state_file.questions.esign_declaration.edit.submit')

      expect(page).to have_text I18n.t("state_file.questions.submission_confirmation.edit.title", state_name: "Arizona")
      expect(page).to have_link I18n.t("state_file.questions.submission_confirmation.edit.download_state_return_pdf")
      click_on "Main XML Doc"

      expect(page.body).to include('efile:ReturnState')
      expect(page.body).to include('<FirstName>Titus</FirstName>')
      expect(page.body).to include('<QualParentsAncestors>')
      expect(page.body).to include('<WageAmIndian>100</WageAmIndian>')
      expect(page.body).to include('<CompNtnlGrdArmdFrcs>100</CompNtnlGrdArmdFrcs>')

      assert_flow_explorer_sample_params_includes_everything('az')

      perform_enqueued_jobs
      submission = EfileSubmission.last
      expect(submission.submission_bundle).to be_present
      expect(submission.current_state).to eq("queued")
    end
  end
end
