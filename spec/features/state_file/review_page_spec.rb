require "rails_helper"

RSpec.feature "Completing a state file intake", active_job: true, js: true do
  include MockTwilio
  include StateFileIntakeHelper

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
        wait_for_device_info("income_review")
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
        wait_for_device_info("income_review")
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
        wait_for_device_info("income_review")
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
        wait_for_device_info("income_review")
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

  context "NC" do
    before do
      allow(Flipper).to receive(:enabled?).and_call_original
      allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
      state_code = "nc"
      set_up_intake_and_associated_records(state_code)

      intake = StateFile::StateInformationService.intake_class(state_code).last
      # First 1099R already created in set_up_intake_and_associated_records
      second_1099r = create(:state_file1099_r, intake: intake, payer_name: "The People's Free Food Emporium")
      third_1099r = create(:state_file1099_r, intake: intake, payer_name: "Boone Community Garden")
      StateFileNc1099RFollowup.create(state_file1099_r: intake.state_file1099_rs.first, income_source: "bailey_settlement", bailey_settlement_at_least_five_years: "yes")
      StateFileNc1099RFollowup.create(state_file1099_r: second_1099r, income_source: "uniformed_services", uniformed_services_retired: "no", uniformed_services_qualifying_plan: "no")
      StateFileNc1099RFollowup.create(state_file1099_r: third_1099r, income_source: "other")

      visit "/questions/#{state_code}-review"
    end

    it "allows user to view and edit their 1099R followup information" do
      within "#retirement-income-source-0" do
        expect(page).to have_text "Dorothy Red"
        expect(page).to have_text I18n.t("state_file.questions.nc_review.edit.retirement_income_source_bailey_settlement")
        expect(page).to have_text I18n.t("state_file.questions.nc_review.edit.bailey_settlement_at_least_five_years")
      end

      within "#retirement-income-source-1" do
        expect(page).to have_text "The People's Free Food Emporium"
        expect(page).to have_text I18n.t("state_file.questions.nc_review.edit.retirement_income_source_uniformed_services")
        expect(page).to have_text I18n.t("state_file.questions.nc_review.edit.none_apply")
      end

      within "#retirement-income-source-2" do
        expect(page).to have_text "Boone Community Garden"
        expect(page).to have_text I18n.t("state_file.questions.nc_review.edit.none_apply")
      end

      within "#retirement-income-source-0" do
        click_on I18n.t("general.review_and_edit")
      end

      check I18n.t("state_file.questions.nc_retirement_income_subtraction.edit.bailey_settlement_from_retirement_plan")
      click_on I18n.t("general.continue")

      within "#retirement-income-source-0" do
        expect(page).to have_text "Dorothy Red"
        expect(page).to have_text I18n.t("state_file.questions.nc_review.edit.retirement_income_source_bailey_settlement")
        expect(page).to have_text I18n.t("state_file.questions.nc_review.edit.bailey_settlement_at_least_five_years")
        expect(page).to have_text I18n.t("state_file.questions.nc_review.edit.bailey_settlement_from_retirement_plan")
      end

      within "#retirement-income-source-1" do
        expect(page).to have_text "The People's Free Food Emporium"
        expect(page).to have_text I18n.t("state_file.questions.nc_review.edit.retirement_income_source_uniformed_services")
        expect(page).to have_text I18n.t("state_file.questions.nc_review.edit.none_apply")
      end

      within "#retirement-income-source-2" do
        expect(page).to have_text "Boone Community Garden"
        expect(page).to have_text I18n.t("state_file.questions.nc_review.edit.none_apply")
      end
    end
  end

  context "MD" do
    before do
      allow(Flipper).to receive(:enabled?).and_call_original
      allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
      state_code = "md"
      set_up_intake_and_associated_records(state_code)

      intake = StateFile::StateInformationService.intake_class(state_code).last

      second_1099r = create(:state_file1099_r, intake: intake, payer_name: "Maryland State Retirement")
      third_1099r = create(:state_file1099_r, intake: intake, payer_name: "Baltimore County Pension")

      StateFileMd1099RFollowup.create(state_file1099_r: intake.state_file1099_rs.first, income_source: "pension_annuity_endowment")
      StateFileMd1099RFollowup.create(state_file1099_r: second_1099r, income_source: "other", service_type: "military")
      StateFileMd1099RFollowup.create(state_file1099_r: third_1099r, income_source: "other", service_type: "public_safety")

      visit "/questions/#{state_code}-review"
    end

    it "allows user to view and edit their 1099R followup information" do
      within "#retirement-income-source-0" do
        expect(page).to have_text "Dorothy Red"
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.pension_annuity_endowment")
      end

      within "#retirement-income-source-1" do
        expect(page).to have_text "Maryland State Retirement"
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.other")
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.military")
      end

      within "#retirement-income-source-2" do
        expect(page).to have_text "Baltimore County Pension"
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.other")
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.public_safety")
      end

      within "#retirement-income-source-0" do
        click_on I18n.t("general.review_and_edit")
      end

      choose I18n.t("state_file.questions.md_retirement_income_subtraction.edit.income_source_other")
      choose I18n.t("state_file.questions.md_retirement_income_subtraction.edit.service_type_military")
      click_on I18n.t("general.continue")

      within "#retirement-income-source-0" do
        expect(page).to have_text "Dorothy Red"
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.other")
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.military")
      end

      within "#retirement-income-source-1" do
        expect(page).to have_text "Maryland State Retirement"
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.other")
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.military")
      end

      within "#retirement-income-source-2" do
        expect(page).to have_text "Baltimore County Pension"
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.other")
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.public_safety")
      end
    end

    it "allows user to view and edit their disability status" do
      within "#permanently-disabled" do
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.disability_status")
        expect(page).to have_text I18n.t("general.negative")

        click_on I18n.t("general.review_and_edit")
      end

      choose "Yes", name: "state_file_md_permanently_disabled_form[primary_disabled]"
      choose "No", name: "state_file_md_permanently_disabled_form[proof_of_disability_submitted]"
      click_on I18n.t("general.continue")

      within "#permanently-disabled" do
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.disability_status")
        expect(page).to have_text I18n.t("general.affirmative")
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.proof_of_disability")
        expect(page).to have_text I18n.t("general.negative")
      end
    end

    it "displays joint disability status correctly when filing MFJ" do
      intake = StateFile::StateInformationService.intake_class("md").last
      intake.direct_file_data.filing_status = 2 # mfj
      intake.update(raw_direct_file_data: intake.direct_file_data, spouse_birth_date: Date.new(1994, 12, 31))
      visit "/questions/md-review"

      within "#permanently-disabled" do
        expect(page).to have_text I18n.t("state_file.questions.md_permanently_disabled.edit.no_neither")

        click_on I18n.t("general.review_and_edit")
      end

      choose "Yes, we both are"
      choose "No"
      click_on I18n.t("general.continue")

      within "#permanently-disabled" do
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.disability_status")
        expect(page).to have_text I18n.t("state_file.questions.md_permanently_disabled.edit.yes_both")
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.proof_of_disability")
        expect(page).to have_text I18n.t("general.negative")
      end
    end
  end

  context "ID" do
    before do
      allow(Flipper).to receive(:enabled?).and_call_original
      allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)

      state_code = "id"
      set_up_intake_and_associated_records(state_code)

      @intake = StateFile::StateInformationService.intake_class(state_code).last
      first_1099r = @intake.state_file1099_rs.first
      first_1099r.update(taxable_amount: 200)
      StateFileId1099RFollowup.create(state_file1099_r: @intake.state_file1099_rs.first, eligible_income_source: "yes")
      allow_any_instance_of(StateFile::Questions::IdRetirementAndPensionIncomeController).to receive(:person_qualifies?).and_return(true)

      second_1099r = create(:state_file1099_r, intake: @intake, payer_name: "Couch Potato Cafe", taxable_amount: 50)
      StateFileId1099RFollowup.create(state_file1099_r: second_1099r, eligible_income_source: "yes")

      # making this value always greater than 8e so 8f value always gets used
      allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_8d).and_return(first_1099r.taxable_amount + second_1099r.taxable_amount + 1)
    end

    context "with line 8e value greater than 0" do
      context "with eligible senior at least 65 years old" do # current fixture has filer who is 65 years old
        it "should allow review & edit by navigating back to answer questions on eligible_income_source and go through every 1099Rs that are applicable, then return to review" do
          visit "/questions/id-review"

          within "#qualified-retirement-benefits-deduction" do
            expect(page).to have_text I18n.t("state_file.questions.id_review.edit.qualified_retirement_benefits_deduction")
            expect(page).to have_text I18n.t("state_file.questions.id_review.edit.qualified_retirement_benefits_deduction_explain")
            expect(page).to have_text I18n.t("state_file.questions.id_review.edit.qualified_disabled_retirement_benefits")
            expect(page).to have_text "$250.00"

            click_on I18n.t("general.review_and_edit")
          end
          expect(page).to have_text I18n.t("state_file.questions.id_retirement_and_pension_income.edit.subtitle")
        end
      end

      context "with eligible disabled senior under 65 years old" do
        before do
          @intake.update(primary_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 64), 12, 31))
        end

        it "should allow review & edit by navigating back to answer questions on disability, and ask about eligible_income_source for every applicable 1099R, only if disabled, then return to review" do
          visit "/questions/id-review"

          within "#qualified-retirement-benefits-deduction" do
            expect(page).to have_text I18n.t("state_file.questions.id_review.edit.qualified_retirement_benefits_deduction")
            expect(page).to have_text I18n.t("state_file.questions.id_review.edit.qualified_retirement_benefits_deduction_explain")
            expect(page).to have_text I18n.t("state_file.questions.id_review.edit.qualified_disabled_retirement_benefits")
            expect(page).to have_text "$250.00"

            click_on I18n.t("general.review_and_edit")
          end
          expect(page).to have_text I18n.t("state_file.questions.id_disability.edit.title")
        end
      end
    end

    it "should not show the Qualified Retirement Benefits Deduction card if line 8e is not positive" do
      allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_8e).and_return(0)
      visit "/questions/id-review"

      expect(page).not_to have_text(I18n.t("state_file.questions.id_review.edit.qualified_retirement_benefits_deduction"))
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
      df_data_import_succeeded_at: DateTime.now,
      primary_first_name: "Deedee",
      primary_last_name: "Doodoo",
      primary_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 65), 12, 1),
    )
    intake.direct_file_data.fed_unemployment = 1000
    intake.update(raw_direct_file_data: intake.direct_file_data)
    create(:state_file_w2, state_file_intake: intake, box14_fli: 0, box14_ui_wf_swf: 0, box14_stpickup: 0)
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
