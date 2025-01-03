require "rails_helper"
require 'axe-capybara'
require 'axe-rspec'

RSpec.feature "Completing a state file intake", active_job: true do
  include MockTwilio
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  context "NY", :flow_explorer_screenshot, js: true do
    it "has content", required_schema: "ny" do
      visit "/"
      click_on "Start Test NY"

      expect(page).to have_text I18n.t("state_file.landing_page.edit.ny.title")
      click_on I18n.t('general.get_started'), id: "firstCta"

      step_through_eligibility_screener(us_state: "ny")

      step_through_initial_authentication(contact_preference: :email)

      check "Email"
      check "Text message"
      fill_in "Your phone number", with: "+12025551212"
      click_on "Continue"

      expect(page).to have_text I18n.t('state_file.questions.sms_terms.edit.title')
      click_on I18n.t("general.accept")

      expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
      click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

      step_through_df_data_transfer

      expect(page).to have_text I18n.t("state_file.questions.nyc_residency.edit.title", year: filing_year)
      choose "I did not live in New York City at all in #{filing_year}"
      choose I18n.t("general.affirmative")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.eligibility_offboarding.edit.ineligible_reason.nyc_maintained_home")
      click_on "Go back"
      expect(page).to have_text I18n.t("state_file.questions.nyc_residency.edit.title", year: filing_year)
      choose "I lived in New York City all year in #{filing_year}"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.ny_county.edit.title", filing_year: filing_year)
      select("Nassau", from: "County")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.ny_school_district.edit.title", filing_year: filing_year)
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

      expect(page).to have_text I18n.t('state_file.questions.ny_sales_use_tax.edit.title.one', year: filing_year)
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

      expect(page).to have_text I18n.t('state_file.questions.unemployment.edit.title')
      choose I18n.t("general.affirmative")
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_name'), with: "Business Name"
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_address'), with: "123 Main St"
      fill_in I18n.t('state_file.questions.unemployment.edit.city'), with: "New York", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.zip_code'), with: "11102", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_tin'), with: "270293117"
      choose I18n.t('state_file.questions.unemployment.edit.confirm_address_yes')
      fill_in 'state_file1099_g_unemployment_compensation_amount', with: "123"
      fill_in 'state_file1099_g_federal_income_tax_withheld_amount', with: "456"
      fill_in 'state_file1099_g_state_identification_number', with: "123456789"
      fill_in 'state_file1099_g_state_income_tax_withheld_amount', with: "789"
      click_on I18n.t("general.continue")

      expect(page).to have_text(I18n.t('state_file.questions.unemployment.index.1099_label', name: StateFileNyIntake.last.primary.full_name))
      click_on I18n.t("general.continue")

      # From the review page, the user can go back to certain screens to edit and then should return directly to the
      # review page. This is well-covered by unit tests, but let's test just one of those screens here
      expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
      within "#county" do
        click_on I18n.t("general.edit")
      end
      expect(page).to have_text I18n.t("state_file.questions.ny_county.edit.title", filing_year: filing_year)
      click_on I18n.t("general.continue")
      expect(page).to have_text I18n.t("state_file.questions.ny_school_district.edit.title", filing_year: filing_year)
      click_on I18n.t("general.continue")
      expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
      click_on I18n.t("general.continue")

      expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.tax_refund.edit.title_html", state_name: "New York", refund_amount: 1468))
      expect(page).not_to have_text "Your responses are saved. If you need a break, you can come back and log in to your account at fileyourstatetaxes.org."
      choose I18n.t("state_file.questions.tax_refund.edit.mail")
      click_on I18n.t("general.continue")

      expect(page).to have_text(I18n.t('state_file.questions.esign_declaration.edit.title', state_name: "New York"))
      expect(page).to have_text("I have examined the information on my NYS electronic tax return, including all information transferred to my NYS return from my federal return")
      check "state_file_esign_declaration_form_primary_esigned"
      click_on I18n.t('state_file.questions.esign_declaration.edit.submit')

      expect(page).to have_text I18n.t("state_file.questions.submission_confirmation.edit.title", state_name: "New York", filing_year: filing_year)
      expect(page).to have_link I18n.t("state_file.questions.submission_confirmation.edit.download_state_return_pdf")
      click_on "Main XML Doc"
      expect(page.body).to include('ReturnState')
      expect(page.body).to include('<FirstName>Testy</FirstName>')

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
    it "has content", required_schema: "az" do
      visit "/"
      click_on "Start Test AZ"

      expect(page).to have_text I18n.t("state_file.landing_page.edit.az.title")
      click_on I18n.t('general.get_started'), id: "firstCta"

      click_on I18n.t("general.continue")

      step_through_initial_authentication(contact_preference: :email)

      check "Email"
      check "Text message"
      fill_in "Your phone number", with: "+12025551212"
      click_on "Continue"

      expect(page).to have_text I18n.t('state_file.questions.sms_terms.edit.title')
      click_on I18n.t("general.accept")

      expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
      click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

      step_through_df_data_transfer("Transfer Old sample")

      expect(page).to have_text I18n.t("state_file.questions.az_senior_dependents.edit.title", dependents_name_list: "Grampy")
      expect(page).to have_text I18n.t("state_file.questions.az_senior_dependents.edit.assistance_label", name: "Grampy")
      expect(page).to have_text I18n.t("state_file.questions.az_senior_dependents.edit.passed_away_label", name: "Grampy", filing_year: filing_year)
      choose "state_file_az_senior_dependents_form_dependents_attributes_0_needed_assistance_yes"
      choose "state_file_az_senior_dependents_form_dependents_attributes_0_passed_away_no"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.az_prior_last_names.edit.title.one")
      choose "state_file_az_prior_last_names_form_has_prior_last_names_yes"
      fill_in "state_file_az_prior_last_names_form_prior_last_names", with: "Jordan, Pippen, Rodman"
      click_on I18n.t("general.continue")

      expect(page).to have_text "Here are the income forms we transferred from your federal tax return."
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.unemployment.edit.title', year: filing_year)
      choose I18n.t("general.affirmative")
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_name'), with: "Business Name"
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_address'), with: "123 Main St"
      fill_in I18n.t('state_file.questions.unemployment.edit.city'), with: "Phoenix", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.zip_code'), with: "85001", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_tin'), with: "123456789"
      choose I18n.t('state_file.questions.unemployment.edit.confirm_address_yes')
      fill_in 'state_file1099_g_unemployment_compensation_amount', with: "123"
      fill_in 'state_file1099_g_federal_income_tax_withheld_amount', with: "456"
      fill_in 'state_file1099_g_state_identification_number', with: "123456789"
      fill_in 'state_file1099_g_state_income_tax_withheld_amount', with: "789"
      click_on I18n.t("general.continue")

      expect(page).to have_text(I18n.t('state_file.questions.unemployment.index.1099_label', name: StateFileAzIntake.last.primary.full_name))
      click_on I18n.t("general.continue")

      expect(strip_html_tags(page.body)).to have_text strip_html_tags(I18n.t('state_file.questions.az_public_school_contributions.edit.title_html'))
      choose I18n.t("general.affirmative")
      fill_in "az322_contribution_school_name", with: "Tax Elementary"
      fill_in "az322_contribution_ctds_code", with: "123456789"
      fill_in "az322_contribution_district_name", with: "Testerson"
      fill_in "az322_contribution_amount", with: "200"
      select_cfa_date "az322_contribution_date_of_contribution", Date.new(filing_year, 6, 21)
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.az_public_school_contributions.index.title')
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.az_charitable_contributions.edit.title")
      choose I18n.t("general.affirmative")
      fill_in I18n.t("state_file.questions.az_charitable_contributions.edit.charitable_cash_html"), with: "123"
      fill_in I18n.t("state_file.questions.az_charitable_contributions.edit.charitable_noncash_html"), with: "123"
      click_on I18n.t("general.continue")

      expect(strip_html_tags(page.body)).to have_text strip_html_tags(I18n.t('state_file.questions.az_qualifying_organization_contributions.form.main_heading_html', filing_year: filing_year))
      choose I18n.t("general.affirmative")
      fill_in "az321_contribution_charity_name", with: "Center for Ants"
      fill_in "az321_contribution_charity_code", with: "21134"
      fill_in "az321_contribution_amount", with: "90"
      select_cfa_date "az321_contribution_date_of_contribution", Date.new(filing_year, 6, 21)

      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.az_qualifying_organization_contributions.index.title')

      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.az_subtractions.edit.title.one", year: MultiTenantService.statefile.current_tax_year)
      check "state_file_az_subtractions_form_tribal_member"
      fill_in "state_file_az_subtractions_form_tribal_wages_amount", with: "100"
      check "state_file_az_subtractions_form_armed_forces_member"
      fill_in "state_file_az_subtractions_form_armed_forces_wages_amount", with: "100"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.primary_state_id.edit.title')
      choose I18n.t('state_file.questions.primary_state_id.state_id.id_type_question.dmv')
      fill_in I18n.t('state_file.questions.primary_state_id.state_id.id_details.number'), with: "012345678"
      select_cfa_date "state_file_primary_state_id_form_issue_date", 4.years.ago.beginning_of_year
      select_cfa_date "state_file_primary_state_id_form_expiration_date", 4.years.from_now.beginning_of_year
      select("Arizona", from: I18n.t('state_file.questions.primary_state_id.state_id.id_details.issue_state'))
      click_on I18n.t("general.continue")

      # From the review page, the user can go back to certain screens to edit and then should return directly to the
      # review page. This is well-covered by unit tests, but let's test just one of those screens here
      expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
      within "#prior-last-names" do
        click_on I18n.t("general.edit")
      end
      expect(page).to have_text I18n.t("state_file.questions.az_prior_last_names.edit.title.one")
      click_on I18n.t("general.continue")
      expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
      click_on I18n.t("general.continue")

      expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.tax_refund.edit.title_html", state_name: "Arizona", refund_amount: 1239))
      expect(page).not_to have_text "Your responses are saved. If you need a break, you can come back and log in to your account at fileyourstatetaxes.org."

      choose I18n.t("state_file.questions.tax_refund.edit.direct_deposit")
      expect(page).to have_text I18n.t("state_file.questions.tax_refund.bank_details.bank_title")
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

      expect(page).to have_text I18n.t("state_file.questions.submission_confirmation.edit.title", state_name: "Arizona", filing_year: filing_year)
      expect(page).to have_link I18n.t("state_file.questions.submission_confirmation.edit.download_state_return_pdf")

      click_on "Main XML Doc"

      expect(page.body).to include('efile:ReturnState')
      expect(page.body).to include('<FirstName>Testy</FirstName>')
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

  context "NC", :flow_explorer_screenshot, js: true do
    before do
      allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:refund_or_owed_amount).and_return 1000
    end

    it "has content", required_schema: "nc" do
      visit "/"
      click_on "Start Test NC"

      expect(page).to have_text I18n.t("state_file.landing_page.edit.nc.title")
      click_on I18n.t('general.get_started'), id: "firstCta"

      step_through_eligibility_screener(us_state: "nc")

      step_through_initial_authentication(contact_preference: :email)

      check "Email"
      check "Text message"
      fill_in "Your phone number", with: "+12025551212"
      click_on "Continue"

      expect(page).to have_text I18n.t('state_file.questions.sms_terms.edit.title')
      click_on I18n.t("general.accept")

      expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
      click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

      step_through_df_data_transfer("Transfer Nick")

      expect(page).to have_text I18n.t("state_file.questions.nc_county.edit.title", filing_year: filing_year)
      select("Buncombe", from: "County")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.nc_veteran_status.title_spouse")
      choose "state_file_nc_veteran_status_form_primary_veteran_no"
      choose "state_file_nc_veteran_status_form_spouse_veteran_no"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.nc_sales_use_tax.edit.title.other", year: filing_year, count: 2)
      choose I18n.t("general.negative")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.unemployment.edit.title', year: filing_year)
      choose I18n.t("general.affirmative")
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_name'), with: "Business Name"
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_address'), with: "123 Main St"
      fill_in I18n.t('state_file.questions.unemployment.edit.city'), with: "Asheville", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.zip_code'), with: "28806", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_tin'), with: "123456789"
      choose I18n.t('state_file.questions.unemployment.edit.recipient_myself')
      choose I18n.t('state_file.questions.unemployment.edit.confirm_address_yes')
      fill_in 'state_file1099_g_unemployment_compensation_amount', with: "123"
      fill_in 'state_file1099_g_federal_income_tax_withheld_amount', with: "456"
      fill_in 'state_file1099_g_state_identification_number', with: "123456789"
      fill_in 'state_file1099_g_state_income_tax_withheld_amount', with: "789"
      click_on I18n.t("general.continue")

      expect(page).to have_text(I18n.t('state_file.questions.unemployment.index.1099_label', name: StateFileNcIntake.last.primary.full_name))
      click_on I18n.t("general.continue")

      expect(strip_html_tags(page.body)).to have_text strip_html_tags(I18n.t("state_file.questions.nc_subtractions.edit.title_html.other"))
      choose I18n.t("general.negative")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.primary_state_id.state_id.id_type_question.label")
      choose I18n.t("state_file.questions.primary_state_id.state_id.id_type_question.drivers_license")
      fill_in "state_file_primary_state_id_form_id_number", with: "123456789"
      select_cfa_date "state_file_primary_state_id_form_issue_date", Date.new(2020, 1, 1)
      check "state_file_primary_state_id_form_non_expiring"
      select("Alaska", from: "State")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.primary_state_id.state_id.id_type_question.label")
      choose I18n.t("state_file.questions.primary_state_id.state_id.id_type_question.drivers_license")
      fill_in "state_file_spouse_state_id_form_id_number", with: "123456789"
      select_cfa_date "state_file_spouse_state_id_form_issue_date", Date.new(2020, 1, 1)
      check "state_file_spouse_state_id_form_non_expiring"
      select("Alaska", from: "State")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
      click_on I18n.t("general.continue")

      expect(strip_html_tags(page.body)).to include strip_html_tags(I18n.t("state_file.questions.nc_tax_refund.edit.title_html", refund_amount: 1000))
      choose I18n.t("state_file.questions.tax_refund.edit.mail")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.esign_declaration.edit.title", state_name: "North Carolina")
      check I18n.t("state_file.questions.esign_declaration.edit.primary_esign")
      check I18n.t("state_file.questions.esign_declaration.edit.spouse_esign")
      click_on I18n.t("state_file.questions.esign_declaration.edit.submit")

      expect(page).to have_text I18n.t("state_file.questions.submission_confirmation.edit.title", state_name: "North Carolina", filing_year: filing_year)

      click_on "Main XML Doc"

      expect(page.body).to include('efile:ReturnState')
      expect(page.body).to include('<FirstName>Nick</FirstName>')
      expect(page.body).to include('<DisasterReliefTxt>Buncombe_Helene</DisasterReliefTxt>')
      expect(page.body).to include('<NCCountyCode>011</NCCountyCode>')
      expect(page.body).to include('<DrvrLcnsStCd>AK</DrvrLcnsStCd>')

      perform_enqueued_jobs
      submission = EfileSubmission.last
      expect(submission.submission_bundle).to be_present
      expect(submission.current_state).to eq("queued")
    end
  end

  context "ID", :flow_explorer_screenshot, js: true do
    it "has content", required_schema: "id" do
      visit "/"
      click_on "Start Test ID"

      expect(page).to have_text I18n.t("state_file.landing_page.edit.id.title")
      click_on I18n.t('general.get_started'), id: "firstCta"

      step_through_eligibility_screener(us_state: "id")

      step_through_initial_authentication(contact_preference: :email)

      check "Email"
      check "Text message"
      fill_in "Your phone number", with: "+12025551212"
      click_on "Continue"

      expect(page).to have_text I18n.t('state_file.questions.sms_terms.edit.title')
      click_on I18n.t("general.accept")

      expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
      click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

      step_through_df_data_transfer

      expect(page).to have_text "Here are the income forms we transferred from your federal tax return."
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.unemployment.edit.title', year: filing_year)
      choose I18n.t("general.affirmative")
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_name'), with: "Business Name"
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_address'), with: "123 Main St"
      fill_in I18n.t('state_file.questions.unemployment.edit.city'), with: "Boise", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.zip_code'), with: "85001", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_tin'), with: "123456789"
      choose I18n.t('state_file.questions.unemployment.edit.confirm_address_yes')
      fill_in 'state_file1099_g_unemployment_compensation_amount', with: "123"
      fill_in 'state_file1099_g_federal_income_tax_withheld_amount', with: "456"
      fill_in 'state_file1099_g_state_identification_number', with: "123456789"
      fill_in 'state_file1099_g_state_income_tax_withheld_amount', with: "789"
      click_on I18n.t("general.continue")

      # 1099G Review
      click_on I18n.t("general.continue")

      # Health Insurance Premium
      expect(page).to have_text I18n.t('state_file.questions.id_health_insurance_premium.edit.title')
      choose I18n.t("general.affirmative")
      fill_in 'state_file_id_health_insurance_premium_form_health_insurance_paid_amount', with: "1234.60"
      click_on I18n.t("general.continue")

      # Grocery Credit Edit
      expect(page).to have_text I18n.t("state_file.questions.id_grocery_credit.edit.see_if_you_qualify.other")
      choose I18n.t("general.negative")
      click_on I18n.t("general.continue")

      # Grocery Credit Review
      expect(page).to have_text I18n.t("state_file.questions.id_grocery_credit_review.edit.would_you_like_to_donate")
      choose I18n.t("general.negative")
      click_on I18n.t("general.continue")

      # Sales/Use Tax
      expect(page).to have_text I18n.t('state_file.questions.id_sales_use_tax.edit.title.one', year: filing_year)
      choose I18n.t("general.affirmative")
      fill_in 'state_file_id_sales_use_tax_form_total_purchase_amount', with: "290"
      click_on I18n.t("general.continue")

      # Permanent Building Fund
      expect(page).to have_text I18n.t('state_file.questions.id_permanent_building_fund.edit.title')
      choose I18n.t("general.negative")
      click_on I18n.t("general.continue")

      # State IDs
      expect(page).to have_text I18n.t('state_file.questions.id_primary_state_id.id_primary.title')
      click_on I18n.t("state_file.questions.id_primary_state_id.id_primary.why_ask_this")
      # expect Idaho specific help text
      expect(page).to have_text I18n.t('state_file.questions.id_primary_state_id.id_primary.protect_identity')
      choose I18n.t('state_file.questions.primary_state_id.state_id.id_type_question.dmv')
      fill_in I18n.t('state_file.questions.primary_state_id.state_id.id_details.number'), with: "012345678"
      select_cfa_date "state_file_primary_state_id_form_issue_date", 4.years.ago.beginning_of_year
      select_cfa_date "state_file_primary_state_id_form_expiration_date", 4.years.from_now.beginning_of_year
      select("Idaho", from: I18n.t('state_file.questions.primary_state_id.state_id.id_details.issue_state'))
      click_on I18n.t("general.continue")

      # ID Review page
      expect(page).to have_text "Idaho Health Insurance Premium Subtraction"
      expect(page).to have_text "$1,234.60"
      click_on I18n.t("general.continue")

      # Refund page
      expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.tax_refund.edit.title_html", state_name: "Idaho", refund_amount: 1452))
      expect(page).not_to have_text "Your responses are saved. If you need a break, you can come back and log in to your account at fileyourstatetaxes.org."
      choose I18n.t("state_file.questions.tax_refund.edit.mail")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.esign_declaration.edit.title", state_name: "Idaho")
      check I18n.t("state_file.questions.esign_declaration.edit.primary_esign")
      click_on I18n.t("state_file.questions.esign_declaration.edit.submit")

      expect(page).to have_text I18n.t("state_file.questions.submission_confirmation.edit.title", state_name: "Idaho", filing_year: filing_year)

      click_on "Main XML Doc"

      expect(page.body).to include('efile:ReturnState')
      expect(page.body).to include('<FirstName>Testy</FirstName>')
      expect(page.body).to include('<HealthInsurancePaid>1235</HealthInsurancePaid>')
      expect(page.body).to include('<GroceryCredit>240</GroceryCredit>')

      perform_enqueued_jobs
      submission = EfileSubmission.last
      expect(submission.submission_bundle).to be_present
      expect(submission.current_state).to eq("queued")
    end
  end

  context "MD", :flow_explorer_screenshot, js: true do
    before do
      # TODO: replace fixture used here with one that has all the characteristics we want to test
      allow_any_instance_of(DirectFileData).to receive(:fed_unemployment).and_return 100
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:refund_or_owed_amount).and_return 1000
    end

    it "has content", required_schema: "md" do
      visit "/"
      click_on "Start Test MD"

      expect(page).to have_text I18n.t("state_file.landing_page.edit.md.title")
      click_on I18n.t('general.get_started'), id: "firstCta"

      expect(page).to have_text I18n.t("state_file.questions.md_eligibility_filing_status.edit.title", year: filing_year)
      # select optoins that allow us to proceed
      click_on "Continue"

      step_through_eligibility_screener(us_state: "md")

      step_through_initial_authentication(contact_preference: :email)

      check "Email"
      check "Text message"
      fill_in "Your phone number", with: "+12025551212"
      click_on "Continue"

      expect(page).to have_text I18n.t('state_file.questions.sms_terms.edit.title')
      click_on I18n.t("general.accept")

      expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
      click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

      step_through_df_data_transfer("Transfer Zeus two w2s")

      expect(page).to have_text I18n.t("state_file.questions.md_permanent_address.edit.title", filing_year: filing_year)
      choose I18n.t("general.affirmative")
      click_on I18n.t("general.continue")

      expect(page).to have_text "Select the county and political subdivision where you lived on December 31, #{filing_year}"
      select("Allegany", from: "County")
      select("Town Of Barton", from: "state_file_md_county_form_subdivision_code")
      click_on I18n.t("general.continue")

      expect(page).to have_text "Here are the income forms we transferred from your federal tax return."
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.unemployment.edit.title', year: filing_year)
      choose I18n.t("general.affirmative")
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_name'), with: "Business Name"
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_address'), with: "123 Main St"
      fill_in I18n.t('state_file.questions.unemployment.edit.city'), with: "Baltimore", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.zip_code'), with: "85001", match: :first
      fill_in I18n.t('state_file.questions.unemployment.edit.payer_tin'), with: "123456789"
      choose I18n.t('state_file.questions.unemployment.edit.recipient_my_spouse')
      choose I18n.t('state_file.questions.unemployment.edit.confirm_address_yes')
      fill_in 'state_file1099_g_unemployment_compensation_amount', with: "123"
      fill_in 'state_file1099_g_federal_income_tax_withheld_amount', with: "456"
      fill_in 'state_file1099_g_state_identification_number', with: "123456789"
      fill_in 'state_file1099_g_state_income_tax_withheld_amount', with: "789"
      click_on I18n.t("general.continue")
      click_on I18n.t("general.continue")

      # md_two_income_subtractions
      expect(page).to have_text I18n.t('state_file.questions.md_two_income_subtractions.edit.title', year: filing_year)
      fill_in 'state_file_md_two_income_subtractions_form[primary_student_loan_interest_ded_amount]', with: "1300.0"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.primary_state_id.edit.title')
      choose I18n.t('state_file.questions.md_primary_state_id.md_primary.dmv_bmv_label')

      fill_in I18n.t('state_file.questions.primary_state_id.state_id.id_details.number'), with: "012345678"
      select_cfa_date "state_file_primary_state_id_form_issue_date", 4.years.ago.beginning_of_year
      select_cfa_date "state_file_primary_state_id_form_expiration_date", 4.years.from_now.beginning_of_year
      select("Maryland", from: I18n.t('state_file.questions.primary_state_id.state_id.id_details.issue_state'))
      click_on I18n.t("general.continue")

      choose I18n.t("state_file.questions.primary_state_id.state_id.id_type_question.no_id")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
      click_on I18n.t("general.continue")

      expect(strip_html_tags(page.body)).to have_text strip_html_tags(I18n.t("state_file.questions.tax_refund.edit.title_html", state_name: "Maryland", refund_amount: 1000))
      choose I18n.t('state_file.questions.tax_refund.edit.direct_deposit')
      choose I18n.t("views.questions.bank_details.account_type.checking")
      check "Check here if you have a joint account"
      fill_in 'state_file_md_tax_refund_form_account_holder_first_name', with: "Zeus"
      fill_in 'state_file_md_tax_refund_form_account_holder_middle_initial', with: "A"
      fill_in 'state_file_md_tax_refund_form_account_holder_last_name', with: "Thunder"
      fill_in 'state_file_md_tax_refund_form_joint_account_holder_first_name', with: "Hera"
      fill_in 'state_file_md_tax_refund_form_joint_account_holder_last_name', with: "Thunder"
      fill_in 'state_file_md_tax_refund_form_routing_number', with: "019456124"
      fill_in 'state_file_md_tax_refund_form_routing_number_confirmation', with: "019456124"
      fill_in 'state_file_md_tax_refund_form_account_number', with: "123456789"
      fill_in 'state_file_md_tax_refund_form_account_number_confirmation', with: "123456789"
      check I18n.t('state_file.questions.md_tax_refund.edit.bank_authorization_confirmation')
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.md_had_health_insurance.edit.title")
      choose I18n.t("general.affirmative")
      check "Zeus L Thunder"
      within "#answer-no-health-insurance" do
        choose I18n.t("general.affirmative")
      end
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.esign_declaration.edit.title", state_name: "Maryland")
      fill_in 'state_file_esign_declaration_form_primary_signature_pin', with: "12345"
      fill_in 'state_file_esign_declaration_form_spouse_signature_pin', with: "54321"
      check I18n.t("state_file.questions.esign_declaration.edit.primary_esign")
      check I18n.t("state_file.questions.esign_declaration.edit.spouse_esign")
      check "state_file_esign_declaration_form_primary_esigned"
      check "state_file_esign_declaration_form_spouse_esigned"
      click_on I18n.t("state_file.questions.esign_declaration.edit.submit")

      expect(page).to have_text I18n.t("state_file.questions.submission_confirmation.edit.title", state_name: "Maryland", filing_year: filing_year)
      expect(page).to have_link I18n.t("state_file.questions.submission_confirmation.edit.download_state_return_pdf")

      click_on "Main XML Doc"

      expect(page.body).to include('efile:ReturnState')
      expect(page.body).to include('<FirstName>Zeus</FirstName>')
      expect(page.body).to include('<CityTownOrTaxingArea>Town Of Barton</CityTownOrTaxingArea>')
      expect(page.body).to include('<TaxpayerPIN>12345</TaxpayerPIN>')
      expect(page.body).to include('<TaxpayerPIN>54321</TaxpayerPIN>')

      perform_enqueued_jobs
      submission = EfileSubmission.last
      expect(submission.submission_bundle).to be_present
      expect(submission.current_state).to eq("queued")
    end
  end

  context "NJ", :flow_explorer_screenshot, js: true do

    def advance_to_start_of_intake(df_persona_name)
      visit "/"
      click_on "Start Test NJ"

      expect(page).to have_text I18n.t("state_file.landing_page.edit.nj.title")
      click_on "Get Started", id: "firstCta"

      continue

      step_through_initial_authentication(contact_preference: :email)

      check "Email"
      check "Text message"
      fill_in "Your phone number", with: "+12025551212"
      click_on "Continue"

      expect(page).to have_text I18n.t('state_file.questions.sms_terms.edit.title')
      click_on I18n.t("general.accept")

      expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
      click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

      step_through_df_data_transfer("Transfer #{df_persona_name}")

      expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
      continue
    end

    def advance_health_insurance_eligibility
      expect(page).to have_text I18n.t("state_file.questions.nj_eligibility_health_insurance.edit.title")
      choose I18n.t("general.affirmative")
      continue
    end

    def advance_county_and_municipality(county = "Atlantic", municipality = "Atlantic City")
      select county
      continue

      select municipality
      continue
    end

    def advance_disabled_exemption(selection = false)
      # disabled exemption
      page.all(:css, '.white-group').each do |group|
        within group do
          choose selection ? I18n.t('general.affirmative') : I18n.t('general.negative')
        end
      end
      continue
    end

    def advance_veterans_exemption(selection = false)
      # veterans exemption
      page.all(:css, '.white-group').each do |group|
        within group do
          choose selection ? I18n.t('general.affirmative') : I18n.t('general.negative')
        end
      end
      continue
    end

    def advance_medical_expenses(amount = 1000)
      fill_in I18n.t('state_file.questions.nj_medical_expenses.edit.label', filing_year: filing_year), with: amount
      continue
    end

    def continue
      click_on I18n.t("general.continue")
    end

    def choose_household_rent_own(household_rent_own)
      case household_rent_own
      when "homeowner", "tenant", "both", "neither"
        choose I18n.t("state_file.questions.nj_household_rent_own.edit.#{household_rent_own}")
      else
        throw "not a valid choice"
      end
      continue
    end

    def select_homeowner_eligibility(checkboxes)
      expect(page).to have_text I18n.t("state_file.questions.nj_homeowner_eligibility.edit.title", filing_year: filing_year)
      checkboxes.each do |checkbox|
        check I18n.t("state_file.questions.nj_homeowner_eligibility.edit.#{checkbox}")
      end
      continue
    end

    def select_tenant_eligibility(checkboxes)
      expect(page).to have_text I18n.t("state_file.questions.nj_tenant_eligibility.edit.title", filing_year: filing_year)
      checkboxes.each do |checkbox|
        check I18n.t("state_file.questions.nj_tenant_eligibility.edit.#{checkbox}")
      end
      continue
    end

    def fill_property_tax_paid(amount, municipality = "Atlantic City")
      expect(page).to have_text I18n.t("state_file.questions.nj_homeowner_property_tax.edit.title", filing_year: filing_year, municipality: municipality)
      fill_in I18n.t('state_file.questions.nj_homeowner_property_tax.edit.label', filing_year: filing_year), with: amount
      continue
    end

    def fill_rent_paid(amount)
      expect(page).to have_text I18n.t("state_file.questions.nj_tenant_rent_paid.edit.title", filing_year: filing_year)
      fill_in I18n.t('state_file.questions.nj_tenant_rent_paid.edit.label', filing_year: filing_year), with: amount
      continue
    end

    def expect_estimated_tax_page
      expect(page).to have_text I18n.t("state_file.questions.nj_estimated_tax_payments.edit.title", filing_year: filing_year)
    end

    def expect_ineligible_page(property, reason)
      valid_property_values = ["on_home", "on_rental", nil]
      valid_reasons = ["multi_unit_conditions", "property_taxes", "neither"]
      throw "not a valid property value: #{property}" unless valid_property_values.include?(property)
      throw "not a valid reason value: #{reason}" unless valid_reasons.include?(reason)

      reason_text = I18n.t("state_file.questions.nj_ineligible_property_tax.edit.reason_#{reason}", filing_year: MultiTenantService.statefile.current_tax_year)
      property_text = property.present? ? I18n.t("state_file.questions.nj_ineligible_property_tax.edit.#{property}") : nil
      expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.nj_ineligible_property_tax.edit.title_html", property: property_text)).strip
      expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.nj_ineligible_property_tax.edit.reason_html", reason: reason_text))
      continue
    end

    def advance_to_property_tax_page(df_persona_name, skip_health_insurance_eligibility: false)
      advance_to_start_of_intake(df_persona_name)
      advance_health_insurance_eligibility unless skip_health_insurance_eligibility
      advance_county_and_municipality
      advance_disabled_exemption
      advance_veterans_exemption
      advance_medical_expenses
    end

    it "advances past the loading screen by listening for an actioncable broadcast", required_schema: "nj" do

      advance_to_property_tax_page("Minimal", skip_health_insurance_eligibility: true)
      choose_household_rent_own("neither")

      # estimated tax payments
      fill_in I18n.t('state_file.questions.nj_estimated_tax_payments.edit.label', filing_year: MultiTenantService.statefile.current_tax_year), with: 1000
      continue

      # sales use tax
      choose I18n.t('general.negative')
      continue

      # Gubernatorial elections fund
      choose I18n.t('general.affirmative')
      expect(page).to be_axe_clean.within "main"
      continue

      # Driver License
      choose I18n.t('state_file.questions.nj_primary_state_id.nj_primary.no_id')
      expect(page).to be_axe_clean.within "main"
      continue

      # Tax Refund
      expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.tax_refund.edit.title_html", refund_amount: 1000, state_name: "New Jersey"))
      expect(page).to be_axe_clean.within "main"
      choose I18n.t('state_file.questions.tax_refund.edit.mail')
      continue

      # Review
      expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
      expect(page).to be_axe_clean.within "main"

      groups = page.all(:css, '.white-group').count
      h2s = page.all(:css, 'h2').count
      expect(groups).to eq(h2s - 1) # account for the h2 reveal button

      edit_buttons = page.all(:css, '.white-group a')
      edit_buttons_count = edit_buttons.count
      edit_buttons_with_sr_only_text = page.all(:css, '.white-group a span.sr-only').count
      expect(edit_buttons_count).to eq(edit_buttons_with_sr_only_text)

      edit_buttons_text = edit_buttons.map(&:text)
      edit_buttons_unique_text_count = edit_buttons_text.uniq.count
      expect(edit_buttons_unique_text_count).to eq(edit_buttons_count)

      click_on I18n.t("state_file.questions.nj_review.edit.reveal.header")
      amounts_in_calculation_details = page.all(:xpath, '//main/section[last()]//p[contains(text(),"$")]')
      expect(amounts_in_calculation_details.count).to eq(19)
    end

    it "handles property tax neither flow", required_schema: "nj" do
      advance_to_property_tax_page("Zeus one dep")
      choose_household_rent_own("neither")
      expect_ineligible_page(nil, "neither")
      expect_estimated_tax_page
    end

    context "when tenant" do
      it "handles property tax eligible tenant flow", required_schema: "nj" do
        advance_to_property_tax_page("Zeus one dep")
        choose_household_rent_own("tenant")
        select_tenant_eligibility(["tenant_home_subject_to_property_taxes"])
        fill_rent_paid(10000)
        expect_estimated_tax_page
      end

      it "handles property tax ineligible tenant flow", required_schema: "nj" do
        advance_to_property_tax_page("Zeus one dep")
        choose_household_rent_own("tenant")
        select_tenant_eligibility([])
        expect_ineligible_page("on_rental", "property_taxes")
        expect_estimated_tax_page
      end
    end

    context "when homeowner" do
      it "handles property tax eligible homeowner flow", required_schema: "nj" do
        advance_to_property_tax_page("Zeus one dep")
        choose_household_rent_own("homeowner")
        select_homeowner_eligibility(["homeowner_home_subject_to_property_taxes"])
        fill_property_tax_paid(10000)
        expect_estimated_tax_page
      end

      it "handles property tax ineligible homeowner flow", required_schema: "nj" do
        advance_to_property_tax_page("Zeus one dep")
        choose_household_rent_own("homeowner")
        select_homeowner_eligibility([])
        expect_ineligible_page("on_home", "property_taxes")
        expect_estimated_tax_page
      end
    end

    context "when both homeowner and tenant" do
      it "handles property tax eligible both homeowner & tenant flow", required_schema: "nj" do
        advance_to_property_tax_page("Zeus one dep")
        choose_household_rent_own("both")
        select_homeowner_eligibility(["homeowner_home_subject_to_property_taxes"])
        fill_property_tax_paid(10000)
        select_tenant_eligibility(["tenant_home_subject_to_property_taxes"])
        fill_rent_paid(10000)
        expect_estimated_tax_page
      end

      it "handles property tax both flow - eligible homeowner & ineligible tenant", required_schema: "nj" do
        advance_to_property_tax_page("Zeus one dep")
        choose_household_rent_own("both")
        select_homeowner_eligibility(["homeowner_home_subject_to_property_taxes"])
        fill_property_tax_paid(10000)
        select_tenant_eligibility([])
        expect_ineligible_page("on_rental", "property_taxes")
        expect_estimated_tax_page
      end

      it "handles property tax both flow - ineligible homeowner & eligible tenant", required_schema: "nj" do
        advance_to_property_tax_page("Zeus one dep")
        choose_household_rent_own("both")
        select_homeowner_eligibility([])
        expect_ineligible_page("on_home", "property_taxes")
        select_tenant_eligibility(["tenant_home_subject_to_property_taxes"])
        fill_rent_paid(10000)
        expect_estimated_tax_page
      end
    end

    context "when low income but meets exception" do
      it "handles property tax flow - eligible homeowner", required_schema: "nj" do
        advance_to_start_of_intake("Minimal") # low income
        advance_county_and_municipality
        advance_disabled_exemption(true) # disabled exemption
        advance_veterans_exemption
        advance_medical_expenses
        choose_household_rent_own("homeowner")
        select_homeowner_eligibility(["homeowner_home_subject_to_property_taxes"])
        # skips property tax paid page
        expect_estimated_tax_page
      end

      it "handles property tax flow - eligible tenant", required_schema: "nj" do
        advance_to_start_of_intake("Minimal") # low income
        advance_county_and_municipality
        advance_disabled_exemption(true) # disabled exemption
        advance_veterans_exemption
        advance_medical_expenses
        choose_household_rent_own("tenant")
        select_tenant_eligibility(["tenant_home_subject_to_property_taxes"])
        # skips rent paid page
        expect_estimated_tax_page
      end

      it "handles property tax flow - when both and eligible homeowner", required_schema: "nj" do
        advance_to_start_of_intake("Minimal") # low income
        advance_county_and_municipality
        advance_disabled_exemption(true) # disabled exemption
        advance_veterans_exemption
        advance_medical_expenses
        choose_household_rent_own("both")
        select_homeowner_eligibility(["homeowner_home_subject_to_property_taxes"])
        # skips property tax paid page
        # skips tenant eligibility page (because they only need to qualify for one type of eligibility)
        expect_estimated_tax_page
      end

      it "handles property tax both flow - ineligible homeowner and eligible tenant", required_schema: "nj" do
        advance_to_start_of_intake("Minimal") # low income
        advance_county_and_municipality
        advance_disabled_exemption(true) # disabled exemption
        advance_veterans_exemption
        advance_medical_expenses
        choose_household_rent_own("both")
        select_homeowner_eligibility([])
        expect_ineligible_page("on_home", "property_taxes")
        select_tenant_eligibility(["tenant_home_subject_to_property_taxes"])
        # skips rent paid page
        expect_estimated_tax_page
      end
    end
  end
end
