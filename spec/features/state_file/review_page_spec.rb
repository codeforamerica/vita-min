require "rails_helper"

RSpec.feature "Completing a state file intake", active_job: true do
  include MockTwilio
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  context "AZ", js: true do
    it "allows user to navigate to income review page, edit an income form, and then navigate back to final review page", required_schema: "az" do
      visit "/"
      click_on "Start Test AZ"

      expect(page).to have_text I18n.t("state_file.landing_page.edit.az.title")
      click_on I18n.t('general.get_started'), id: "firstCta"

      step_through_eligibility_screener(us_state: "az")

      step_through_initial_authentication(contact_preference: :email)

      expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')

      intake = StateFileAzIntake.last
      intake.update(
        raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml("az_df_complete_sample"),
        primary_first_name: "Ariz",
        primary_last_name: "Onian",
        primary_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 65), 12, 1),
      )
      create(:state_file_w2, state_file_intake: intake)
      create(:state_file1099_r, intake: intake)

      visit "/questions/az-review"

      # Final review page
      expect(page).to have_text I18n.t("state_file.questions.shared.review_header.title")
      within "#income-info" do
        click_on I18n.t("general.edit")
      end

      # Income review page
      expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
      within "#w2s" do
        click_on I18n.t("state_file.questions.income_review.edit.review_and_edit_state_info")
      end

      # W2 edit page
      expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.w2.edit.instructions_1_html", employer: intake.state_file_w2s.first.employer_name))
      fill_in strip_html_tags(I18n.t("state_file.questions.w2.edit.box15_html")), with: "987654321"
      click_on I18n.t("general.continue")

      # Back on income review page
      expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
      click_on I18n.t("general.continue")

      # Final review page
      expect(page).to have_text I18n.t("state_file.questions.shared.review_header.title")
      within "#income-info" do
        click_on I18n.t("general.edit")
      end

      # Income review page
      expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
      within "#form1099rs" do
        click_on I18n.t("state_file.questions.income_review.edit.review_and_edit_state_info")
      end

      # 1099R edit page
      expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.retirement_income.edit.title", payer_name: intake.state_file1099_rs.first.payer_name))
      fill_in strip_html_tags(I18n.t("state_file.questions.retirement_income.edit.box15_html")), with: "123456789"
      click_on I18n.t("general.continue")

      # Back on income review page
      expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
      click_on I18n.t("general.continue")

      # Final review page
      expect(page).to have_text I18n.t("state_file.questions.shared.review_header.title")
      within "#income-info" do
        click_on I18n.t("general.edit")
      end

      # Income review page
      expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
      within "#form1099rs" do
        click_on I18n.t("state_file.questions.income_review.edit.review_and_edit_state_info")
      end

      # 1099R edit page
      expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.retirement_income.edit.title", payer_name: intake.state_file1099_rs.first.payer_name))
      fill_in strip_html_tags(I18n.t("state_file.questions.retirement_income.edit.box15_html")), with: "123456789"
      click_on I18n.t("general.continue")

      # Back on income review page
      expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
      click_on I18n.t("general.continue")

      # Final review page
      expect(page).to have_text I18n.t("state_file.questions.shared.review_header.title")
    end
  end
end
