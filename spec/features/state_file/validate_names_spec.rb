require "rails_helper"

RSpec.feature "Validating filer names against the federal return", active_job: true do
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  context "NY single", :flow_explorer_screenshot, js: true do
    it "shows a warning notice on the page but doesn't prevent them from moving on" do
      visit "/"
      click_on "Start Test NY"
      expect(page).to have_text I18n.t("state_file.questions.landing_page.edit.ny.title")
      click_on I18n.t('general.get_started'), id: "firstCta"
      step_through_eligibility_screener(us_state: "ny")
      step_through_initial_authentication(contact_preference: :email)
      expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
      click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")
      step_through_df_data_transfer("Transfer NY Albert single 8k")

      # name dob page
      expect(page).to have_text I18n.t("state_file.questions.name_dob.edit.title1")
      expect(page).to have_text I18n.t("state_file.questions.name_dob.edit.title2")
      expect(page).to have_text "Your responses are saved. If you need a break, you can come back and log in to your account at fileyourstatetaxes.org."

      fill_in "state_file_name_dob_form[primary_last_name]", with: "Uova"
      expect(page).to have_text "Your last name does not match the last name you entered on your federal return. Please double check the spelling of your name."

      fill_in "state_file_name_dob_form[primary_first_name]", with: "Abbie"
      expect(page).to have_text "Your first name does not match the first name you entered on your federal return. Please double check the spelling of your name."

      select_cfa_date "state_file_name_dob_form_primary_birth_date", Date.new(1978, 6, 21)
      click_on I18n.t("general.continue")

      # they can still get to the next page
      expect(page).to have_text I18n.t("state_file.questions.nyc_residency.edit.title", year: 2023)
    end
  end

  context "AZ mfj", :flow_explorer_screenshot, js: true do
    it "shows a warning notice for both primary and spouse on the page but doesn't prevent them from moving on" do
      visit "/"
      click_on "Start Test AZ"
      expect(page).to have_text I18n.t("state_file.questions.landing_page.edit.az.title")
      click_on I18n.t('general.get_started'), id: "firstCta"
      step_through_eligibility_screener(us_state: "az")
      step_through_initial_authentication(contact_preference: :email)
      expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
      click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")
      step_through_df_data_transfer("Transfer AZ Goldwater")

      expect(page).to have_text I18n.t("state_file.questions.name_dob.edit.title1")
      expect(page).to have_text I18n.t("state_file.questions.name_dob.edit.title2")
      expect(page).to have_text "Your responses are saved. If you need a break, you can come back and log in to your account at fileyourstatetaxes.org."

      fill_in "state_file_name_dob_form_primary_last_name", with: "Moldwater"
      expect(page).to have_text "Your last name does not match the last name you entered on your federal return. Please double check the spelling of your name."

      fill_in "state_file_name_dob_form_primary_first_name", with: "Mary"
      expect(page).to have_text "Your first name does not match the first name you entered on your federal return. Please double check the spelling of your name."

      fill_in "state_file_name_dob_form_spouse_last_name", with: "Moldwater"
      expect(page).to have_text "Your spouse's last name does not the last name you entered on your federal return. Please double check the spelling of your spouse's name."

      fill_in "state_file_name_dob_form_spouse_first_name", with: "Barry"
      select_cfa_date "state_file_name_dob_form_primary_birth_date", Date.new(1978, 6, 21)
      click_on I18n.t("general.continue")

      # they can still get to the next page
      expect(page).to have_text I18n.t("state_file.questions.az_senior_dependents.edit.title")
    end
  end
end
