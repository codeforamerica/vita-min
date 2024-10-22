require "rails_helper"

RSpec.feature "Income Review", active_job: true do
  include MockTwilio
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  context "AZ", :flow_explorer_screenshot, js: true do
    it "allows review of 1099-R information and edit", required_schema: "az" do
      visit "/"
      click_on "Start Test AZ"

      expect(page).to have_text I18n.t("state_file.landing_page.edit.az.title")
      click_on I18n.t('general.get_started'), id: "firstCta"

      step_through_eligibility_screener(us_state: "az")

      step_through_initial_authentication(contact_preference: :email)

      expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
      click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

      step_through_df_data_transfer("Transfer Richard retirement 1099r")

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
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.az_prior_last_names.edit.title.one")
      choose "state_file_az_prior_last_names_form_has_prior_last_names_no"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.income_review.edit.title')
      expect(page).to have_text "Payer Name"
      expect(page).to have_text "Second Payer Name"

      within(".retirement-income") do |element|
        element.first(:link, "Review and edit state info").click
      end
      expect(page).not_to have_text "First two letters must be az"
      click_on I18n.t("general.continue")
      expect(page).to have_text "First two letters must be az"
      fill_in "state_file1099_r_payer_state_identification_number", with: "az111111111"
      click_on I18n.t("general.continue")
      expect(page).to have_text I18n.t('state_file.questions.income_review.edit.title')
    end
  end

  context "NC", :flow_explorer_screenshot, js: true do
    it "allows review of 1099-R information and edit", required_schema: "nc" do
      visit "/"
      click_on "Start Test NC"

      expect(page).to have_text I18n.t("state_file.landing_page.edit.nc.title")
      click_on I18n.t('general.get_started'), id: "firstCta"

      step_through_eligibility_screener(us_state: "nc")

      step_through_initial_authentication(contact_preference: :email)

      expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
      click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

      step_through_df_data_transfer("Transfer Miranda 1099r")

      expect(page).to have_text I18n.t("state_file.questions.data_review.edit.title")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.name_dob.edit.title1")
      expect(page).to have_text I18n.t("state_file.questions.name_dob.edit.title2")
      expect(page).to have_text "Your responses are saved. If you need a break, you can come back and log in to your account at fileyourstatetaxes.org."
      fill_in "state_file_name_dob_form_primary_first_name", with: "Titus"
      fill_in "state_file_name_dob_form_primary_last_name", with: "Testerson"
      select_cfa_date "state_file_name_dob_form_primary_birth_date", Date.new(1978, 6, 21)
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.nc_county.edit.title", filing_year: MultiTenantService.statefile.current_tax_year)
      select("Alamance", from: "County")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.nc_veteran_status.title")
      choose "state_file_nc_veteran_status_form_primary_veteran_no"
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.nc_sales_use_tax.edit.title", year: MultiTenantService.statefile.current_tax_year, count: 1)
      choose I18n.t("general.negative")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.income_review.edit.title')
      expect(page).to have_text "Susan Miranda"
      expect(page).to have_text "Payer Name"
      expect(page).to have_text "Payer 2 Name"

      within(".retirement-income") do |element|
        element.first(:link, "Review and edit state info").click
      end

      # placeholder values shown for nil values
      expect(page).to have_css("#state_file1099_r_state_distribution_amount[value='0.0']")
      expect(page).to have_css("#state_file1099_r_state_tax_withheld_amount[value='0.0']")
      expect(page.find_by_id('state_file1099_r_payer_state_identification_number').value).to eq("")

      click_on I18n.t("general.continue")

      expect(page).to have_text "Can't be blank"
      fill_in "state_file1099_r_payer_state_identification_number", with: "nc111111111"

      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.income_review.edit.title')
    end
  end

  context "ID", :flow_explorer_screenshot, js: true do
    it "has content", required_schema: "id" do
      visit "/"
      click_on "Start Test ID"

      expect(page).to have_text I18n.t("state_file.landing_page.edit.id.title")
      click_on I18n.t('general.get_started'), id: "firstCta"

      step_through_initial_authentication(contact_preference: :email)

      expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
      click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

      step_through_df_data_transfer("Transfer Miranda 1099r")

      expect(page).to have_text I18n.t("state_file.questions.data_review.edit.title")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.income_review.edit.title')
      expect(page).to have_text "Susan Miranda"
      expect(page).to have_text "Payer Name"
      expect(page).to have_text "Payer 2 Name"

      within(".retirement-income") do |element|
        element.all(:link, "Review and edit state info")[1].click
      end

      # placeholder values shown for nil values
      expect(page).to have_css("#state_file1099_r_state_distribution_amount[value='2000.0']")
      expect(page).to have_css("#state_file1099_r_state_tax_withheld_amount[value='0.0']")
      expect(page.find_by_id('state_file1099_r_payer_state_identification_number').value).to eq("")

      click_on I18n.t("general.continue")

      expect(page).to have_text "Can't be blank"
      fill_in "state_file1099_r_payer_state_identification_number", with: "id111111111"

      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.income_review.edit.title')
    end
  end

  context "MD", :flow_explorer_screenshot, js: true do
    it "has content", required_schema: "md" do
      visit "/"
      click_on "Start Test MD"

      expect(page).to have_text I18n.t("state_file.landing_page.edit.md.title")
      click_on I18n.t('general.get_started'), id: "firstCta"

      expect(page).to have_text I18n.t("state_file.questions.eligible.edit.title1")
      click_on "Continue"

      step_through_initial_authentication(contact_preference: :email)

      expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
      click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

      step_through_df_data_transfer("Transfer Miranda 1099r")

      expect(page).to have_text I18n.t("state_file.questions.data_review.edit.title")
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.income_review.edit.title')
      expect(page).to have_text "Susan Miranda"
      expect(page).to have_text "Payer Name"
      expect(page).to have_text "Payer 2 Name"

      within(".retirement-income") do |element|
        element.first(:link, "Review and edit state info").click
      end

      # placeholder values shown for nil values
      expect(page).to have_css("#state_file1099_r_state_distribution_amount[value='0.0']")
      expect(page).to have_css("#state_file1099_r_state_tax_withheld_amount[value='0.0']")
      expect(page.find_by_id('state_file1099_r_payer_state_identification_number').value).to eq("")

      click_on I18n.t("general.continue")

      expect(page).to have_text "Can't be blank"
      fill_in "state_file1099_r_payer_state_identification_number", with: "md111111111"

      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t('state_file.questions.income_review.edit.title')
    end
  end
end
