require "rails_helper"
require 'axe-capybara'
require 'axe-rspec'

RSpec.feature "Completing a state file intake", active_job: true do
  include MockTwilio
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
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
      expect(page).to have_text I18n.t("state_file.questions.az_prior_last_names.edit.subtitle", start_year: MultiTenantService.statefile.current_tax_year - 4, end_year: MultiTenantService.statefile.current_tax_year - 1)
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

      expect(page).to have_text I18n.t('state_file.questions.income_review.edit.title')
      within('#w2s') do
        expect(page).to have_text(I18n.t('state_file.questions.income_review.edit.no_info_needed'))
      end
      within('#form1099gs') do
        expect(page).to have_text(I18n.t('state_file.questions.income_review.edit.state_info_to_be_collected'))
      end
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

  context "deprecated" do
    context "NY", js: true do
      let(:email_address) { "someone@example.com" }
      let(:ssn) { "111223333" }
      let(:hashed_ssn) { "hashed_ssn" }
      let(:verification_code) { "000004" }
      let(:hashed_verification_code) { "hashed_verification_code" }

      before do
        create :state_file_ny_intake, email_address: email_address, hashed_ssn: hashed_ssn, df_data_import_succeeded_at: 5.minutes.ago
        allow(SsnHashingService).to receive(:hash).with(ssn).and_return hashed_ssn
        allow(VerificationCodeService).to receive(:generate).with(anything).and_return [verification_code, hashed_verification_code]
        allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(email_address, verification_code).and_return(hashed_verification_code)
      end

      it "doesn't allow filers in anymore and redirects all pages to landing page" do
        visit "/"
        click_on "Start Test NY"

        expect(page).to have_text I18n.t("state_file.landing_page.ny_closed.title")

        # spot check a few pages for redirecting to landing page
        visit "/questions/ny-eligibility-residence"
        expect(page).to have_text I18n.t("state_file.landing_page.ny_closed.title")

        visit "/questions/ny-sales-use-tax"
        expect(page).to have_text I18n.t("state_file.landing_page.ny_closed.title")

        visit "/questions/ny-review"
        expect(page).to have_text I18n.t("state_file.landing_page.ny_closed.title")

        # try to log in with existing ny intake and get redirected
        visit "/questions/return-status"
        expect(page).to have_text "Sign in to FileYourStateTaxes"
        click_on "Sign in with email"
        expect(page).to have_text "Sign in with your email address"
        fill_in "Your email address", with: email_address
        perform_enqueued_jobs do
          click_on "Send code"
        end
        expect(page).to have_text "Enter the code to continue"
        fill_in "Enter the 6-digit code", with: verification_code
        click_on "Verify code"
        expect(page).to have_text "Code verified! Authentication needed to continue."
        fill_in "Enter your Social Security number or ITIN. For example, 123-45-6789.", with: ssn
        click_on "Continue"
        expect(page).to have_text I18n.t("state_file.landing_page.ny_closed.title")
      end
    end
  end
end
