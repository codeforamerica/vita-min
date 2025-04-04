require "rails_helper"
require 'axe-capybara'
require 'axe-rspec'

RSpec.feature "Calculating the sales/use tax for a NC intake", js: true do
  include MockTwilio
  include StateFileIntakeHelper

  context "NC" do
    let!(:intake) {
      create :state_file_nc_intake, :with_spouse,
             filing_status: :married_filing_jointly,
             raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml("nc_bert_1099_r"),
             current_step: "/en/questions/nc-veteran-status"
    }

    before do
      login_as(intake, scope: :state_file_nc_intake)
      allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
      allow(Flipper).to receive(:enabled?).and_call_original
      allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
      intake.synchronize_df_dependents_to_database
      intake.synchronize_df_1099_rs_to_database
      intake.synchronize_df_w2s_to_database
      intake.synchronize_filers_to_database
    end

    it "properly calculates", required_schema: "nc" do
      visit "/en/questions/nc-veteran-status"
      page_change_check(I18n.t('state_file.questions.nc_veteran_status.title_spouse'))
      choose "state_file_nc_veteran_status_form_primary_veteran_no"
      choose "state_file_nc_veteran_status_form_spouse_veteran_no"
      click_on I18n.t("general.continue")

      # /en/questions/income-review
      page_change_check(I18n.t('state_file.questions.income_review.edit.title'))
      click_on I18n.t("general.continue")

      # select bailey settlement for the first, and none for the rest
      # /en/questions/nc-retirement-income-subtraction
      page_change_check(I18n.t('state_file.questions.nc_retirement_income_subtraction.edit.title'))
      choose strip_html_tags(I18n.t("state_file.questions.nc_retirement_income_subtraction.edit.income_source_bailey_settlement_html"))
      check "state_file_nc_retirement_income_subtraction_form_bailey_settlement_at_least_five_years"
      check "state_file_nc_retirement_income_subtraction_form_bailey_settlement_from_retirement_plan"
      click_on I18n.t("general.continue")

      page_change_check("/en/questions/nc-retirement-income-subtraction?index=1", path: true)
      choose I18n.t("state_file.questions.nc_retirement_income_subtraction.edit.other")
      click_on I18n.t("general.continue")

      page_change_check("/en/questions/nc-retirement-income-subtraction?index=2", path: true)
      choose I18n.t("state_file.questions.nc_retirement_income_subtraction.edit.other")
      click_on I18n.t("general.continue")

      page_change_check("/en/questions/nc-retirement-income-subtraction?index=3", path: true)
      choose I18n.t("state_file.questions.nc_retirement_income_subtraction.edit.other")
      click_on I18n.t("general.continue")

      page_change_check("/en/questions/nc-subtractions", path: true)
      choose I18n.t("general.negative")
      click_on I18n.t("general.continue")

      # select automated sales use tax calculation
      # /en/questions/nc-sales-use-tax
      page_change_check(I18n.t("state_file.questions.nc_sales_use_tax.edit.title.other", year: filing_year, count: 2))
      choose I18n.t("general.affirmative")
      choose "state_file_nc_sales_use_tax_form_sales_use_tax_calculation_method_automated"
      click_on I18n.t("general.continue")

      expect(page).to have_text(I18n.t("state_file.questions.nc_out_of_country.edit.title", year: filing_year + 1))
      choose I18n.t("general.negative")
      click_on I18n.t("general.continue")

      page_change_check(I18n.t('state_file.questions.primary_state_id.edit.title'))
      choose I18n.t("state_file.questions.primary_state_id.state_id.id_type_question.no_id")
      click_on I18n.t("general.continue")

      page_change_check("/en/questions/spouse-state-id", path: true)
      choose I18n.t("state_file.questions.primary_state_id.state_id.id_type_question.no_id")
      click_on I18n.t("general.continue")

      page_change_check(I18n.t("state_file.questions.shared.abstract_review_header.title"))
      expect(page).to have_css("#use-tax-amount", text: "$11.00")
    end
  end
end
