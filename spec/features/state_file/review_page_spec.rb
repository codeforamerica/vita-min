require "rails_helper"

RSpec.feature "Completing a state file intake", active_job: true do
  include MockTwilio
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  StateFile::StateInformationService.active_state_codes.each do |state_code|
    context "#{state_code.upcase}" do
      it "allows user to navigate to income review page, edit an income form, and then navigate back to final review page", required_schema: "az" do
        visit "/"
        click_on "Start Test #{state_code.upcase}"

        expect(page).to have_text I18n.t("state_file.landing_page.edit.#{state_code}.title")
        click_on I18n.t('general.get_started'), id: "firstCta"
        step_through_eligibility_screener(us_state: state_code)
        step_through_initial_authentication(contact_preference: :email)
        expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')

        intake = StateFile::StateInformationService.intake_class(state_code).last
        intake.update(
          raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml("az_df_complete_sample"),
          primary_first_name: "Deedee",
          primary_last_name: "Doodoo",
          primary_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 65), 12, 1),
        )
        intake.direct_file_data.fed_unemployment = 1000
        intake.update(raw_direct_file_data: intake.direct_file_data)
        create(:state_file_w2, state_file_intake: intake)
        create(:state_file1099_r, intake: intake)
        create(:state_file1099_g, intake: intake)

        visit "/questions/#{state_code}-review"

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
        within "#income-info" do
          click_on I18n.t("general.edit")
        end

        # Income review page
        expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
        within "#form1099gs" do
          click_on I18n.t("state_file.questions.income_review.edit.review_and_edit_state_info")
        end

        # 1099G edit page
        expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.unemployment.edit.title", count: intake.filer_count, year: MultiTenantService.statefile.current_tax_year))
        fill_in strip_html_tags(I18n.t("state_file.questions.unemployment.edit.payer_name")), with: "beepboop"
        click_on I18n.t("general.continue")

        # takes them to the 1099G index page first
        expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.unemployment.index.lets_review"))

        # TODO: click in to edit again and then back to index and then back to review
        # find_by_id('state_file_id_eligibility_residence_form_eligibility_emergency_rental_assistance_no').click

        click_on I18n.t("general.continue")

        # Back on income review page
        expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
        click_on I18n.t("general.continue")

        # Final review page
        expect(page).to have_text I18n.t("state_file.questions.shared.review_header.title")
      end
    end
  end
end
