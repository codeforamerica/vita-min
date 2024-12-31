require "rails_helper"

RSpec.feature "Income Review", active_job: true do
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  context "NJ", :flow_explorer_screenshot, required_schema: "nj", js: true do
    def advance_to_data_transfer
      visit "/"
      click_on "Start Test NJ"
      click_on "Get Started", id: "firstCta"
      click_on I18n.t("general.continue")
      step_through_initial_authentication(contact_preference: :email)
      check "Text message"
      fill_in "Your phone number", with: "+12025551212"
      click_on "Continue"
      click_on I18n.t("general.accept")
      click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")
    end

    def advance_to_income_edit
      advance_to_data_transfer

      step_through_df_data_transfer("Transfer Zeus box 14")

      expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
      expect(page).to have_text I18n.t("state_file.questions.income_review.edit.w2s_title")

      within '#form1099gs' do
        expect(page).to have_text I18n.t("state_file.questions.income_review.edit.unemployment_title")
        expect(page).to have_text I18n.t("state_file.questions.income_review.edit.no_info_needed_nj")
      end
      
      within '#formssa1099s' do
        expect(page).to have_text I18n.t("state_file.questions.income_review.edit.ssa_title")
        expect(page).to have_text I18n.t("state_file.questions.income_review.edit.no_info_needed_nj")
      end

      click_on I18n.t("state_file.questions.income_review.edit.review_and_edit_state_info")
    end

    it "displays review and edit pages with w2s, unemployment, and social security income" do
      advance_to_income_edit

      # STPICKUP 25
      # UIWFSWF 35
      # UIHCWD 45
      # FLI 55

      expect(page).to have_field('state_file_w2_box14_ui_wf_swf', with: '35.0')
      expect(page).to have_field('state_file_w2_box14_fli', with: '55.0')
      expect(page).to have_field('state_file_w2_employer_state_id_num', with: '12345')
      expect(page).to have_field('state_file_w2_state_wages_amount', with: '12345.0')
      expect(page).to have_field('state_file_w2_state_income_tax_amount', with: '500.0')
      expect(page).to have_button("What should I put in Box 14?")
    end

    it "allows ui_wf_swf to be saved up to the limit" do
      advance_to_income_edit

      fill_in 'state_file_w2_box14_ui_wf_swf', with: '179.78'
      click_on 'Continue'

      expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
    end

    it "does not allow ui_wf_swf to be saved above limit" do
      advance_to_income_edit

      fill_in 'state_file_w2_box14_ui_wf_swf', with: '179.79'
      click_on 'Continue'

      expect(page).to have_text("This amount can't exceed $179.78.")
    end


    it "allows fli to be saved up to the limit" do
      advance_to_income_edit

      fill_in 'state_file_w2_box14_fli', with: '145.26'
      click_on 'Continue'

      expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
    end

    it "does not allow fli to be saved above limit" do
      advance_to_income_edit

      fill_in 'state_file_w2_box14_fli', with: '145.27'
      click_on 'Continue'

      expect(page).to have_text("This amount can't exceed $145.26.")
    end

    it "displays with investment income" do
      advance_to_data_transfer

      step_through_df_data_transfer("Transfer Streep single inv limit")

      expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
      expect(page).to have_text I18n.t("state_file.questions.income_review.edit.w2s_title")

      within '#form1099ints' do
        expect(page).to have_text I18n.t("state_file.questions.income_review.edit.interest_income_title")
        expect(page).to have_text I18n.t("state_file.questions.income_review.edit.no_info_needed")
      end
    end
  end
end
