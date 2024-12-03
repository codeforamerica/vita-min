require "rails_helper"
require 'axe-capybara'
require 'axe-rspec'

RSpec.feature "Idaho Grocery Credit nested questions with followup", active_job: true do
  include MockTwilio
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  context "ID", js: true do
    it "doesn't generate additional dependents", required_schema: "id" do
      visit "/"
      click_on "Start Test ID"

      click_on I18n.t('general.get_started'), id: "firstCta"

      find_by_id('state_file_id_eligibility_residence_form_eligibility_withdrew_msa_fthb_no').click
      find_by_id('state_file_id_eligibility_residence_form_eligibility_emergency_rental_assistance_no').click

      click_on I18n.t("general.continue")

      click_on I18n.t("state_file.questions.eligible.edit.not_supported")

      click_on I18n.t("general.continue")

      step_through_initial_authentication(contact_preference: :email)
      check "Email"
      check "Text message"
      fill_in "Your phone number", with: "+12025551212"
      click_on "Continue"

      click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

      step_through_df_data_transfer("Transfer John mfj 8 deps")

      click_on I18n.t("general.continue")

      click_on I18n.t("general.continue")

      # Health Insurance Premium
      choose I18n.t("general.affirmative")
      fill_in 'state_file_id_health_insurance_premium_form_health_insurance_paid_amount', with: "1234.60"
      click_on I18n.t("general.continue")

      # Grocery Credit Edit
      expect(page).to have_text I18n.t("state_file.questions.id_grocery_credit.edit.see_if_you_qualify.other")
      choose I18n.t("general.affirmative")
      choose I18n.t("general.negative")
      click_on I18n.t("general.continue")

      # Grocery Credit Review
      expect(page).to have_text "$1200"
      expect(page).to have_text I18n.t("state_file.questions.id_grocery_credit_review.edit.would_you_like_to_donate")
      choose I18n.t("general.negative")
      click_on I18n.t("general.continue")

    end
  end
end
