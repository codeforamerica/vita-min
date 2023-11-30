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

      expect(page).to have_text "File your New York state taxes for free"
      click_on "Get Started", id: "firstCta"

      step_through_eligibility_screener(us_state: "ny")

      step_through_initial_authentication(contact_preference: :text_message)

      step_through_df_data_transfer

      click_on "visit_federal_info_controller"

      expect(page).to have_field("tax return year", with: "2023")
      select "married filing jointly", from: "state_file_federal_info_form[filing_status]"
      click_on I18n.t("general.continue")

      # name dob page
      expect(page).to have_text "You’re almost done filing!"
      expect(page).to have_text "First, please provide some more information about you and the people in your family"
      fill_in "state_file_name_dob_form[primary_first_name]", with: "Titus"
      fill_in "state_file_name_dob_form[primary_last_name]", with: "Testerson"
      select_cfa_date "state_file_name_dob_form_primary_birth_date", Date.new(1978, 6, 21)

      fill_in "state_file_name_dob_form_spouse_first_name", with: "Taliesen"
      fill_in "state_file_name_dob_form_spouse_last_name", with: "Testerson"
      select_cfa_date "state_file_name_dob_form_spouse_birth_date", Date.new(1979, 6, 22)

      within "#dependent-0" do
        expect(page).to have_text "Your first dependent's name and date of birth"
        expect(page).to have_field("state_file_name_dob_form_dependents_attributes_0_first_name", disabled: true)
        expect(page).to have_field("state_file_name_dob_form_dependents_attributes_0_last_name", disabled: true)

        select_cfa_date "state_file_name_dob_form_dependents_attributes_0_dob", Date.new(2017, 7, 12)
      end
      click_on I18n.t("general.continue")

      expect(page).to have_text "Was this your permanent home address on December 31, 2023?"
      choose I18n.t("general.affirmative")
      click_on I18n.t("general.continue")
      click_on "Go back"

      expect(page).to have_text "Was this your permanent home address on December 31, 2023?"
      choose I18n.t("general.negative")
      # if they previously confirmed their address from DF, don't show it filled in on the form for a new permanent address
      expect(find_field("state_file_ny_permanent_address_form[permanent_street]").value).to eq ""
      fill_in "Street Address", with: "321 Peanut Way"
      fill_in "Apartment/Unit Number", with: "B"
      fill_in "City", with: "New York"
      fill_in "Zip code", with: "11102"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.ny_county.edit.title", filing_year: MultiTenantService.statefile.current_tax_year)
      select("Nassau", from: "County")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.ny_school_district.edit.title", filing_year: MultiTenantService.statefile.current_tax_year)
      select("Bellmore-Merrick CHS Bellmore", from: "School District Name")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.ny_sales_use_tax.edit.title', year: MultiTenantService.statefile.current_tax_year)
      choose I18n.t("general.negative")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.ny_primary_state_id.edit.title')
      choose I18n.t('state_file.questions.ny_primary_state_id.state_id.id_type_question.no_id')
      click_on I18n.t("general.continue")

      expect(page).to have_text "Please provide information for your spouse’s state issued ID"
      choose I18n.t('state_file.questions.ny_primary_state_id.state_id.id_type_question.dmv')
      fill_in  I18n.t('state_file.questions.ny_primary_state_id.state_id.id_details.number'), with: "012345678"
      select_cfa_date "state_file_ny_spouse_state_id_form_issue_date", Time.now - 4.year
      select_cfa_date "state_file_ny_spouse_state_id_form_expiration_date", Time.now + 4.year
      select("New York", from: I18n.t('state_file.questions.ny_primary_state_id.state_id.id_details.issue_state'))
      fill_in  I18n.t('state_file.questions.ny_primary_state_id.state_id.id_details.first_three_doc_num'), with: "ABC"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.unemployment.edit.title')
      choose I18n.t("general.affirmative")
      choose I18n.t('state_file.questions.unemployment.edit.recipient_myself')
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_name'), with: "Business Name"
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_address'), with: "123 Main St"
      fill_in I18n.t('state_file.questions.unemployment.edit.city'), with: "New York", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.zip_code'), with: "11102", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_tin'), with: "123456789"
      choose I18n.t('state_file.questions.unemployment.edit.confirm_address_yes')
      fill_in I18n.t('state_file.questions.unemployment.edit.unemployment_compensation'), with: "123"
      fill_in I18n.t('state_file.questions.unemployment.edit.federal_income_tax_withheld'), with: "456"
      fill_in I18n.t('state_file.questions.unemployment.edit.box_10b'), with: "123456789"
      fill_in I18n.t('state_file.questions.unemployment.edit.state_income_tax_withheld'), with: "789"
      click_on I18n.t("general.continue")

      expect(page).to have_text(I18n.t('state_file.questions.unemployment.index.1099_label', name: StateFileNyIntake.last.primary.full_name))
      click_on I18n.t("general.continue")

      # From the review page, the user can go back to certain screens to edit and then should return directly to the
      # review page. This is well-covered by unit tests, but let's test just one of those screens here
      expect(page).to have_text I18n.t("state_file.questions.ny_review.edit.title1")
      within "#county" do
        click_on I18n.t("general.edit")
      end
      expect(page).to have_text I18n.t("state_file.questions.ny_county.edit.title", filing_year: MultiTenantService.statefile.current_tax_year)
      click_on I18n.t("general.continue")
      expect(page).to have_text I18n.t("state_file.questions.ny_review.edit.title1")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.tax_refund.edit.title", refund_amount: 476, state_name: "New York")
      choose I18n.t("state_file.questions.tax_refund.edit.mail")
      click_on I18n.t("general.continue")

      expect(page).to have_text(I18n.t('state_file.questions.esign_declaration.edit.title', state_name: "New York"))
      expect(page).to have_text("I have examined the information on my 2023 New York State electronic personal income tax return")
      check "state_file_esign_declaration_form_primary_esigned"
      check "state_file_esign_declaration_form_spouse_esigned"
      click_on I18n.t('state_file.questions.esign_declaration.edit.submit')

      expect(page).to have_text I18n.t("state_file.questions.submission_confirmation.edit.title", state_name: "New York")
      expect(page).to have_link I18n.t("state_file.questions.submission_confirmation.edit.download_state_return_pdf")
      click_on "Show XML"
      expect(page.body).to include('efile:ReturnState')
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

      expect(page).to have_text "File your Arizona state taxes for free"
      click_on "Get Started", id: "firstCta"

      step_through_eligibility_screener(us_state: "az")

      step_through_initial_authentication(contact_preference: :email)

      step_through_df_data_transfer

      click_on "visit_federal_info_controller"
      click_on "New Dependent Detail"
      within page.all('.df-dependent-detail-form')[1] do
        fill_in 'DependentSSN', with: "123456789"
        fill_in 'DependentFirstNm', with: "Grampy"
        fill_in 'DependentLastNm', with: "Gramps"
        select "GRANDPARENT", from: "DependentRelationshipCd"
      end
      click_on I18n.t("general.continue")

      expect(page).to have_text "You’re almost done filing!"
      expect(page).to have_text "First, please provide some more information about you and the people in your family"
      fill_in "state_file_name_dob_form_primary_first_name", with: "Titus"
      fill_in "state_file_name_dob_form_primary_last_name", with: "Testerson"

      within "#dependent-0" do
        expect(page).to have_text "Your first dependent's name and date of birth"
        expect(page).to have_field("state_file_name_dob_form_dependents_attributes_0_first_name", disabled: true)
        expect(page).to have_field("state_file_name_dob_form_dependents_attributes_0_last_name", disabled: true)

        select_cfa_date "state_file_name_dob_form_dependents_attributes_0_dob", Date.new(2017, 7, 12)
        select "12", from: "state_file_name_dob_form_dependents_attributes_0_months_in_home"
      end
      within "#dependent-1" do
        select_cfa_date "state_file_name_dob_form_dependents_attributes_1_dob", Date.new(1950, 10, 31)
        select "12", from: "state_file_name_dob_form_dependents_attributes_1_months_in_home"
      end
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.az_senior_dependents.edit.title1")
      expect(page).to have_text I18n.t("state_file.questions.az_senior_dependents.edit.assistance_label", name: "Grampy")
      expect(page).to have_text I18n.t("state_file.questions.az_senior_dependents.edit.passed_away_label", name: "Grampy")
      choose "state_file_az_senior_dependents_form_dependents_attributes_0_needed_assistance_yes"
      choose "state_file_az_senior_dependents_form_dependents_attributes_0_passed_away_no"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.az_prior_last_names.edit.title1")
      choose "state_file_az_prior_last_names_form_has_prior_last_names_yes"
      fill_in "state_file_az_prior_last_names_form_prior_last_names", with: "Jordan, Pippen, Rodman"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.unemployment.edit.title')
      choose I18n.t("general.affirmative")
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_name'), with: "Business Name"
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_address'), with: "123 Main St"
      fill_in I18n.t('state_file.questions.unemployment.edit.city'), with: "Phoenix", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.zip_code'), with: "85001", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_tin'), with: "123456789"
      choose I18n.t('state_file.questions.unemployment.edit.confirm_address_yes')
      fill_in I18n.t('state_file.questions.unemployment.edit.unemployment_compensation'), with: "123"
      fill_in I18n.t('state_file.questions.unemployment.edit.federal_income_tax_withheld'), with: "456"
      fill_in I18n.t('state_file.questions.unemployment.edit.box_10b'), with: "123456789"
      fill_in I18n.t('state_file.questions.unemployment.edit.state_income_tax_withheld'), with: "789"
      click_on I18n.t("general.continue")

      expect(page).to have_text(I18n.t('state_file.questions.unemployment.index.1099_label', name: StateFileAzIntake.last.primary.full_name))
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.az_state_credits.edit.title1")
      check "state_file_az_state_credits_form_tribal_member"
      fill_in "state_file_az_state_credits_form_tribal_wages", with: "100"
      check "state_file_az_state_credits_form_armed_forces_member"
      fill_in "state_file_az_state_credits_form_armed_forces_wages", with: "100"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.az_charitable_contributions.edit.title")
      choose I18n.t("general.affirmative")
      fill_in "Enter the total amount of cash or check contributions made in 2023. (Note: you may be asked to provide receipts for donations over $250.)", with: "123"
      fill_in "Enter the total amount of non-cash contributions made in 2023 (example: the fair market value of donated items). This cannot exceed $500.", with: "123"
      click_on I18n.t("general.continue")

      # From the review page, the user can go back to certain screens to edit and then should return directly to the
      # review page. This is well-covered by unit tests, but let's test just one of those screens here
      expect(page).to have_text I18n.t("state_file.questions.az_review.edit.title1")
      within "#prior-last-names" do
        click_on I18n.t("general.edit")
      end
      expect(page).to have_text I18n.t("state_file.questions.az_prior_last_names.edit.title1")
      click_on I18n.t("general.continue")
      expect(page).to have_text I18n.t("state_file.questions.az_review.edit.title1")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.tax_refund.edit.title", refund_amount: 789, state_name: "Arizona")
      choose I18n.t("state_file.questions.tax_refund.edit.mail")
      click_on I18n.t("general.continue")

      expect(page).to have_text(I18n.t('state_file.questions.esign_declaration.edit.title', state_name: "Arizona"))
      expect(page).to have_text("Under penalties of perjury, I declare that I have examined a copy of my electronic Arizona individual income tax return")
      check "state_file_esign_declaration_form_primary_esigned"
      click_on I18n.t('state_file.questions.esign_declaration.edit.submit')

      expect(page).to have_text I18n.t("state_file.questions.submission_confirmation.edit.title", state_name: "Arizona")
      expect(page).to have_link I18n.t("state_file.questions.submission_confirmation.edit.download_state_return_pdf")
      click_on "Show XML"

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
