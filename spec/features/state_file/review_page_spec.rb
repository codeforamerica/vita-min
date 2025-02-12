require "rails_helper"

RSpec.feature "Completing a state file intake", active_job: true, js: true do
  include MockTwilio
  include StateFileIntakeHelper

  def wait_for_device_info
    sleep(2)
    expect(page.find_all('input[name="state_file_income_review_form[device_id]"]', visible: false).last.value).to be_present
  end

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  StateFile::StateInformationService.active_state_codes.without("ny").each do |state_code|
    context "#{state_code.upcase}" do
      it "allows user to navigate to income review page, edit an income form, and then navigate back to final review page", required_schema: state_code do
        set_up_intake_and_associated_records(state_code)

        intake = StateFile::StateInformationService.intake_class(state_code).last

        visit "/questions/#{state_code}-review"

        # Final review page
        expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
        within "#income-info" do
          expect(page).to have_text "W-2"
          expect(page).to have_text "1099-R"
          expect(page).to have_text "1099-G"
          expect(page).not_to have_text "1099-INT"
          expect(page).not_to have_text "SSA-1099"
          click_on I18n.t("general.edit")
        end

        if intake.allows_w2_editing?
          # Income review page
          expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
          within "#w2s" do
            click_on I18n.t("state_file.questions.income_review.edit.review_and_edit_state_info")
          end

          # W2 edit page
          expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.w2.edit.instructions_1_html", employer: intake.state_file_w2s.first.employer_name))
          fill_in strip_html_tags(I18n.t("state_file.questions.w2.edit.box15_html")), with: "987654321"
          click_on I18n.t("general.continue")
        end

        # Back on income review page
        expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
        wait_for_device_info
        click_on I18n.t("general.continue")

        # Final review page
        expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
        within "#income-info" do
          click_on I18n.t("general.edit")
        end

        # Income review page
        expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
        within "#form1099rs" do
          click_on I18n.t("state_file.questions.income_review.edit.review_and_edit_state_info")
        end

        # 1099R edit page
        expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.retirement_income.edit.title_html", payer_name: intake.state_file1099_rs.first.payer_name))
        fill_in strip_html_tags(I18n.t("state_file.questions.retirement_income.edit.box15_html")), with: "123456789"
        click_on I18n.t("general.continue")

        # Back on income review page
        expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
        wait_for_device_info
        click_on I18n.t("general.continue")

        # Final review page
        expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
        within "#income-info" do
          click_on I18n.t("general.edit")
        end

        # Income review page
        expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
        within "#form1099rs" do
          click_on I18n.t("state_file.questions.income_review.edit.review_and_edit_state_info")
        end

        # 1099R edit page
        expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.retirement_income.edit.title_html", payer_name: intake.state_file1099_rs.first.payer_name))
        fill_in strip_html_tags(I18n.t("state_file.questions.retirement_income.edit.box15_html")), with: "123456789"
        click_on I18n.t("general.continue")

        # Back on income review page
        expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
        wait_for_device_info
        click_on I18n.t("general.continue")

        # Final review page
        expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")

        within "#income-info" do
          click_on I18n.t("general.edit")
        end

        not_taxed_key = "state_file.questions.income_review.edit.no_info_needed_#{state_code}"
        if I18n.exists?(not_taxed_key)
          expect(page).to have_text I18n.t(not_taxed_key)
        else
          edit_unemployment(intake)
        end

        # Back on income review page
        expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
        wait_for_device_info
        click_on I18n.t("general.continue")

        # Final review page
        expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
      end
    end
  end

  context "AZ" do
    it "allows user to navigate to az public school contributions page, edit a contribution form, and then navigate back to final review page", required_schema: "az" do
      state_code = "az"
      set_up_intake_and_associated_records(state_code)

      intake = StateFile::StateInformationService.intake_class(state_code).last

      create :az322_contribution, state_file_az_intake: intake

      visit "/questions/#{state_code}-review"

      # Final review page
      expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
      within "#public-school-contributions" do
        click_on I18n.t("general.edit")
      end

      # public school contribution review page edit navigates to public school contribution index page
      expect(page).to have_text(I18n.t('state_file.questions.az_public_school_contributions.index.title'))
      click_on I18n.t("general.continue")

      # Back on final review page
      expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
      within "#public-school-contributions" do
        click_on I18n.t("general.edit")
      end

      # click Edit on the public school contribution index page (there's only one)
      click_on I18n.t("general.edit")

      # public school contribution edit page
      expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.az_public_school_contributions.edit.title_html"))
      fill_in strip_html_tags(I18n.t("state_file.questions.az_public_school_contributions.edit.school_name")), with: "beepboop"
      click_on I18n.t("general.continue")

      # takes them to the az public school contributions index page first
      expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.az_public_school_contributions.index.title"))
      expect(page).to have_text ("beepboop")
      click_on "Continue"

      # Back on final review page
      expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
      within "#public-school-contributions" do
        click_on I18n.t("general.edit")
      end
    end
  end

  def set_up_intake_and_associated_records(state_code)
    visit "/"
    click_on "Start Test #{state_code.upcase}"

    expect(page).to have_text I18n.t("state_file.landing_page.edit.#{state_code}.title")
    click_on I18n.t('general.get_started'), id: "firstCta"
    step_through_eligibility_screener(us_state: state_code)
    step_through_initial_authentication(contact_preference: :email)

    check "Email"
    check "Text message"
    fill_in "Your phone number", with: "+12025551212"
    click_on "Continue"

    expect(page).to have_text I18n.t('state_file.questions.sms_terms.edit.title')
    click_on I18n.t("general.accept")

    expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')

    intake = StateFile::StateInformationService.intake_class(state_code).last
    intake.update(
      raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml("test_df_complete_sample"),
      raw_direct_file_intake_data: StateFile::DirectFileApiResponseSampleService.new.read_json("test_df_complete_sample"),
      primary_first_name: "Deedee",
      primary_last_name: "Doodoo",
      primary_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 65), 12, 1),
    )
    intake.direct_file_data.fed_unemployment = 1000
    intake.update(raw_direct_file_data: intake.direct_file_data)
    create(:state_file_w2, state_file_intake: intake)
    create(:state_file1099_r, intake: intake)
    create(:state_file1099_g, intake: intake)
  end

  def edit_unemployment(intake)
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

    # edit a 1099G (there's only one)
    click_on I18n.t("general.edit")
    click_on I18n.t("general.continue")

    # back on index page
    expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.unemployment.index.lets_review"))

    # delete a 1099G (there's only one)
    recipient_name = intake.state_file1099_gs.last.recipient_name

    # clicks "OK" on the alert that asks "Are you sure you want to delete this 1099-G?"
    page.accept_confirm do
      click_on I18n.t("general.delete")
    end

    # redirects to new because there are no 1099Gs left, need to select "no" in order to continue
    expect(page).to have_text I18n.t("state_file.questions.unemployment.destroy.removed", name: recipient_name)
    choose I18n.t("general.negative")
    click_on I18n.t("general.continue")
  end
end
