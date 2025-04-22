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
          click_link I18n.t("state_file.questions.income_review.edit.review_and_edit_state_info")
        end

        # 1099R edit or show page
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
          click_link I18n.t("state_file.questions.income_review.edit.review_and_edit_state_info")
        end

        # 1099R edit or show page
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
    before do
      allow(Flipper).to receive(:enabled?).and_call_original
      allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
    end

    it "allows user to navigate to az public school contributions page, edit a contribution form, and then navigate back to final review page, and then to 1099r edit page and back", required_schema: "az" do
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

      # 1099R edit page
      within "#retirement-income-subtractions" do
        click_on I18n.t("general.edit")
      end

      expect(page).to have_text intake.state_file1099_rs.first.payer_name
      choose I18n.t("state_file.questions.az_retirement_income_subtraction.edit.uniformed_services")
      click_on I18n.t("general.continue")

      # Back on final review page
      expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
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
      # Creating a third 1099r that is ineligible to make sure it does not show up on review & doesn't cause issues with review navigation
      create(:state_file1099_r, intake: intake, payer_name: "Not Eligible Place", taxable_amount: 0)
      fourth_1099r = create(:state_file1099_r, intake: intake, payer_name: "Boone Community Garden")
      StateFileNc1099RFollowup.create(state_file1099_r: intake.state_file1099_rs.first, income_source: "bailey_settlement", bailey_settlement_at_least_five_years: "yes")
      StateFileNc1099RFollowup.create(state_file1099_r: second_1099r, income_source: "uniformed_services", uniformed_services_retired: "no", uniformed_services_qualifying_plan: "no")
      StateFileNc1099RFollowup.create(state_file1099_r: fourth_1099r, income_source: "other")

      visit "/questions/#{state_code}-review"
    end

    it "allows user to view and edit their 1099R followup information" do
      expect(page).not_to have_text "Not Eligible Place"

      within "#retirement-income-source-0" do
        expect(page).to have_text "Dorothy Red"
        expect(page).to have_text I18n.t("state_file.questions.shared.nc_retirement_income_deductions_review_header.retirement_income_source_bailey_settlement")
        expect(page).to have_text I18n.t("state_file.questions.shared.nc_retirement_income_deductions_review_header.bailey_settlement_at_least_five_years")
      end

      within "#retirement-income-source-1" do
        expect(page).to have_text "The People's Free Food Emporium"
        expect(page).to have_text I18n.t("state_file.questions.shared.nc_retirement_income_deductions_review_header.retirement_income_source_uniformed_services")
        expect(page).to have_text I18n.t("state_file.questions.shared.nc_retirement_income_deductions_review_header.none_apply")
      end

      within "#retirement-income-source-2" do
        expect(page).to have_text "Boone Community Garden"
        expect(page).to have_text I18n.t("state_file.questions.shared.nc_retirement_income_deductions_review_header.none_apply")
      end

      within "#retirement-income-source-1" do
        click_on I18n.t("general.review_and_edit")
      end

      check I18n.t("state_file.questions.nc_retirement_income_subtraction.edit.uniformed_services_retired")
      click_on I18n.t("general.continue")

      within "#retirement-income-source-0" do
        expect(page).to have_text "Dorothy Red"
        expect(page).to have_text I18n.t("state_file.questions.shared.nc_retirement_income_deductions_review_header.retirement_income_source_bailey_settlement")
        expect(page).to have_text I18n.t("state_file.questions.shared.nc_retirement_income_deductions_review_header.bailey_settlement_at_least_five_years")
      end

      within "#retirement-income-source-1" do
        expect(page).to have_text "The People's Free Food Emporium"
        expect(page).to have_text I18n.t("state_file.questions.shared.nc_retirement_income_deductions_review_header.retirement_income_source_uniformed_services")
        expect(page).to have_text I18n.t("state_file.questions.shared.nc_retirement_income_deductions_review_header.uniformed_twenty_years_medical_retired")
        expect(page).not_to have_text I18n.t("state_file.questions.shared.nc_retirement_income_deductions_review_header.none_apply")
      end

      within "#retirement-income-source-2" do
        expect(page).to have_text "Boone Community Garden"
        expect(page).to have_text I18n.t("state_file.questions.shared.nc_retirement_income_deductions_review_header.none_apply")
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
      intake.update(primary_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 64), 1, 1))

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
        expect(page).to have_text I18n.t("state_file.questions.shared.md_retirement_income_deductions_review_header.pension_annuity_endowment")
      end

      within "#retirement-income-source-1" do
        expect(page).to have_text "Maryland State Retirement"
        expect(page).to have_text I18n.t("state_file.questions.shared.md_retirement_income_deductions_review_header.other")
        expect(page).to have_text I18n.t("state_file.questions.shared.md_retirement_income_deductions_review_header.military")
      end

      within "#retirement-income-source-2" do
        expect(page).to have_text "Baltimore County Pension"
        expect(page).to have_text I18n.t("state_file.questions.shared.md_retirement_income_deductions_review_header.other")
        expect(page).to have_text I18n.t("state_file.questions.shared.md_retirement_income_deductions_review_header.public_safety")
      end

      within "#retirement-income-source-0" do
        click_on I18n.t("general.review_and_edit")
      end

      choose I18n.t("state_file.questions.md_retirement_income_subtraction.edit.income_source_other")
      choose I18n.t("state_file.questions.md_retirement_income_subtraction.edit.service_type_military")
      click_on I18n.t("general.continue")

      within "#retirement-income-source-0" do
        expect(page).to have_text "Dorothy Red"
        expect(page).to have_text I18n.t("state_file.questions.shared.md_retirement_income_deductions_review_header.other")
        expect(page).to have_text I18n.t("state_file.questions.shared.md_retirement_income_deductions_review_header.military")
      end

      within "#retirement-income-source-1" do
        expect(page).to have_text "Maryland State Retirement"
        expect(page).to have_text I18n.t("state_file.questions.shared.md_retirement_income_deductions_review_header.other")
        expect(page).to have_text I18n.t("state_file.questions.shared.md_retirement_income_deductions_review_header.military")
      end

      within "#retirement-income-source-2" do
        expect(page).to have_text "Baltimore County Pension"
        expect(page).to have_text I18n.t("state_file.questions.shared.md_retirement_income_deductions_review_header.other")
        expect(page).to have_text I18n.t("state_file.questions.shared.md_retirement_income_deductions_review_header.public_safety")
      end
    end

    it "allows user to view and edit their disability status" do
      within "#permanently-disabled" do
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.disability_status")
        expect(page).to have_text I18n.t("general.negative")

        click_on I18n.t("general.review_and_edit")
      end

      choose "Yes", name: "state_file_md_permanently_disabled_form[primary_disabled]"
      choose "No", name: "state_file_md_permanently_disabled_form[primary_proof_of_disability_submitted]"
      click_on I18n.t("general.continue")

      within "#permanently-disabled" do
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.disability_status")
        expect(page).to have_text I18n.t("general.affirmative")
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.primary_proof_of_disability")
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

      choose "No", name: "state_file_md_permanently_disabled_form[primary_proof_of_disability_submitted]"
      choose "No", name: "state_file_md_permanently_disabled_form[spouse_proof_of_disability_submitted]"

      click_on I18n.t("general.continue")

      within "#permanently-disabled" do
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.disability_status")
        expect(page).to have_text I18n.t("state_file.questions.md_permanently_disabled.edit.yes_both")
        expect(page).to have_text I18n.t("state_file.questions.md_review.edit.primary_proof_of_disability")
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
      @intake.update(primary_disabled: "no")
      first_1099r = @intake.state_file1099_rs.first
      first_1099r.update(taxable_amount: 200, recipient_ssn: @intake.primary.ssn)
      StateFileId1099RFollowup.create(state_file1099_r: @intake.state_file1099_rs.first, income_source: "civil_service_employee", civil_service_account_number: "zero_to_four")

      second_1099r = create(:state_file1099_r, intake: @intake, payer_name: "Couch Potato Cafe", taxable_amount: 50, recipient_ssn: @intake.primary.ssn)
      StateFileId1099RFollowup.create(state_file1099_r: second_1099r, income_source: "police_officer", police_retirement_fund: "yes")
    end

    context "with eligible 1099Rs" do
      context "with eligible person between 62 and 65 who indicated disability" do
        before do
          @intake.update(primary_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 64), 12, 31), primary_disabled: "yes")
        end

        it "can review & edit disability question and go through all 1099Rs, then return to review" do
          visit "/questions/id-review"

          expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
          within "#qualified-retirement-benefits-deduction" do
            expect(page).to have_text I18n.t("state_file.questions.shared.id_retirement_income_deductions_review_header.subtitle")
            expect(page).to have_text I18n.t("state_file.questions.shared.id_retirement_income_deductions_review_header.civil_servant_employee", taxpayer_name: "Dorothy Jane Red")
            expect(page).to have_text I18n.t("state_file.questions.shared.id_retirement_income_deductions_review_header.police_officer", taxpayer_name: "Dorothy Jane Red")
          end

          within "#disability-info" do
            click_on I18n.t("general.review_and_edit")
          end

          expect(page).to have_text I18n.t("state_file.questions.id_disability.edit.title")
          choose "Yes"
          click_on I18n.t("general.continue")

          # first eligible 1099R
          expect(page).to have_text I18n.t("state_file.questions.id_retirement_and_pension_income.edit.subtitle")
          expect(page).to have_text("Dorothy Red")
          click_on I18n.t("general.continue")

          # second eligible 1099R
          expect(page).to have_text I18n.t("state_file.questions.id_retirement_and_pension_income.edit.subtitle")
          expect(page).to have_text("Couch Potato Cafe")
          expect(page).to have_text("$50")
          choose "None of the above"
          click_on I18n.t("general.continue")

          expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
          within "#qualified-retirement-benefits-deduction" do
            expect(page).to have_text I18n.t("state_file.questions.shared.id_retirement_income_deductions_review_header.subtitle")
            expect(page).to have_text I18n.t("state_file.questions.shared.id_retirement_income_deductions_review_header.civil_servant_employee", taxpayer_name: "Dorothy Jane Red")
            expect(page).to have_text I18n.t("state_file.questions.shared.id_retirement_income_deductions_review_header.none_apply")
          end
        end

        it "can review & edit questions on disability, change answer to No, then return to review without going through 1099-Rs" do
          visit "/questions/id-review"

          expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
          within "#qualified-retirement-benefits-deduction" do
            expect(page).to have_text I18n.t("state_file.questions.shared.id_retirement_income_deductions_review_header.title")
            expect(page).to have_text I18n.t("state_file.questions.shared.id_retirement_income_deductions_review_header.subtitle")
          end

          within "#disability-info" do
            click_on I18n.t("general.review_and_edit")
          end

          expect(page).to have_text I18n.t("state_file.questions.id_disability.edit.title")
          choose "No"
          click_on I18n.t("general.continue")

          expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
          expect(page).not_to have_selector "#qualified-retirement-benefits-deduction"

          expect(page).to have_text I18n.t("state_file.questions.shared.id_disability_review_header.meets_qualifications")
        end

        context "mfj" do
          before do
            allow_any_instance_of(StateFileIdIntake).to receive(:show_mfj_disability_options?).and_return(true)
            @intake.update(
              raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml("id_barrel_roll"),
              raw_direct_file_intake_data: StateFile::DirectFileApiResponseSampleService.new.read_json("id_barrel_roll"),
              spouse_first_name: "Beepbeep",
              spouse_last_name: "Boop",
              spouse_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 65), 12, 2),
              spouse_disabled: "yes" # both disabled
            )

            third_1099r = create(:state_file1099_r, intake: @intake, payer_name: "Third Spouse Inc", taxable_amount: 750, recipient_ssn: @intake.spouse.ssn)
            StateFileId1099RFollowup.create(state_file1099_r: third_1099r, income_source: "police_officer", police_retirement_fund: "yes")
          end

          it "can persist mfj disability question on review & change and persist a new disability state" do
            visit "/questions/id-review"

            page_change_check(I18n.t("state_file.questions.shared.abstract_review_header.title"))

            within "#disability-info" do
              expect(page).to have_text I18n.t("general.affirmative")
              click_on I18n.t("general.review_and_edit")
            end

            page_change_check(I18n.t("state_file.questions.id_disability.edit.title"))
            expect(page.find(:css, '#state_file_id_disability_form_mfj_disability_both')).to be_checked
            choose "Yes, my spouse is"

            click_on I18n.t("general.continue")

            within "#disability-info" do
              expect(page).to have_text I18n.t("general.affirmative")
              click_on I18n.t("general.review_and_edit")
            end

            page_change_check(I18n.t("state_file.questions.id_disability.edit.title"))
            expect(page.find(:css, '#state_file_id_disability_form_mfj_disability_spouse')).to be_checked
          end
        end
      end

      context "with eligible senior over 65 years old" do
        it "review & edit questions on eligible_income_source and go through individual 1099Rs that are applicable, then return to review" do
          visit "/questions/id-review"

          expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")

          expect(page).not_to have_text I18n.t("state_file.questions.shared.id_disability_review_header.meets_qualifications")

          within "#retirement-income-source-0" do
            expect(page).to have_text I18n.t("state_file.questions.shared.id_retirement_income_deductions_review_header.civil_servant_employee", taxpayer_name: "Dorothy Jane Red")
          end

          within "#retirement-income-source-1" do
            expect(page).to have_text I18n.t("state_file.questions.shared.id_retirement_income_deductions_review_header.police_officer", taxpayer_name: "Dorothy Jane Red")
          end

          within "#retirement-income-source-0" do
            click_on I18n.t("general.review_and_edit")
          end

          choose I18n.t("state_file.questions.id_retirement_and_pension_income.edit.military")
          click_on I18n.t("general.continue")

          within "#retirement-income-source-0" do
            expect(page).to have_text I18n.t("state_file.questions.shared.id_retirement_income_deductions_review_header.military", taxpayer_name: "Dorothy Jane Red")
          end
        end

        it "review & edit questions on eligible_income_source and when answers 8 for civil servant account number it goes to offboarding page" do
          visit "/questions/id-review"

          expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
          within "#qualified-retirement-benefits-deduction" do
            expect(page).to have_text I18n.t("state_file.questions.shared.id_retirement_income_deductions_review_header.title")
            expect(page).to have_text I18n.t("state_file.questions.shared.id_retirement_income_deductions_review_header.civil_servant_employee", taxpayer_name: "Dorothy Jane Red")
            expect(page).to have_text I18n.t("state_file.questions.shared.id_retirement_income_deductions_review_header.police_officer", taxpayer_name: "Dorothy Jane Red")
          end

          within "#retirement-income-source-0" do
            expect(page).to have_text I18n.t("state_file.questions.shared.id_retirement_income_deductions_review_header.civil_servant_employee", taxpayer_name: "Dorothy Jane Red")
          end

          within "#retirement-income-source-0" do
            click_on I18n.t("general.review_and_edit")
          end

          # first eligible 1099R
          expect(page).to have_text I18n.t("state_file.questions.id_retirement_and_pension_income.edit.subtitle")
          expect(page).to have_text("Dorothy Red")
          expect(page).to have_text("$200")
          choose "8"
          click_on I18n.t("general.continue")

          # Goes to offboarding page
          expect(page).to have_text I18n.t("state_file.questions.id_ineligible_retirement_and_pension_income.edit.title")

          click_on I18n.t("state_file.questions.id_ineligible_retirement_and_pension_income.edit.file_without_claiming")
          expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
        end
      end
    end
  end

  context "NJ" do
    before do
      allow(Flipper).to receive(:enabled?).and_call_original
      allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)

      state_code = "nj"
      set_up_intake_and_associated_records(state_code)

      @intake = StateFile::StateInformationService.intake_class(state_code).last
      @intake.update(primary_disabled: "no")
      first_1099r = @intake.state_file1099_rs.first
      first_1099r.update(taxable_amount: 200, recipient_ssn: @intake.primary.ssn)
      StateFileNj1099RFollowup.create(state_file1099_r: first_1099r, income_source: "military_survivors_benefits")

      second_1099r = create(:state_file1099_r, intake: @intake, payer_name: "Couch Potato Cafe", taxable_amount: 50, recipient_ssn: @intake.primary.ssn)
      StateFileNj1099RFollowup.create(state_file1099_r: second_1099r, income_source: "military_pension")
    end

    context "with eligible 1099Rs" do
      it "can review & edit all 1099Rs, then return to review" do
        visit "/questions/nj-review"

        expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
        within "#retirement-income-source" do
          expect(page).to have_text I18n.t("state_file.questions.nj_review.edit.retirement_income_source_military_survivor_benefit")
          expect(page).to have_text I18n.t("state_file.questions.nj_review.edit.retirement_income_source_military_pension")
          expect(page).not_to have_text I18n.t("state_file.questions.nj_review.edit.retirement_income_source_other")
          click_on I18n.t("general.review_and_edit")
        end

        # first eligible 1099R
        expect(page).to have_text I18n.t("state_file.questions.nj_retirement_income_source.edit.title")
        expect(page).to have_text("1099-R: Dorothy Red")
        expect(page).to have_text("Taxpayer Name: Dorothy Jane Red")
        expect(page).to have_text("$200")
        expect(page).to have_text I18n.t("state_file.questions.nj_retirement_income_source.edit.label")
        choose I18n.t("state_file.questions.nj_retirement_income_source.edit.option_other")
        click_on I18n.t("general.continue")

        # second eligible 1099R
        expect(page).to have_text I18n.t("state_file.questions.nj_retirement_income_source.edit.title")
        expect(page).to have_text("1099-R: Couch Potato Cafe")
        expect(page).to have_text("Taxpayer Name: Dorothy Jane Red")
        expect(page).to have_text("$50")
        expect(page).to have_text I18n.t("state_file.questions.nj_retirement_income_source.edit.label")
        choose I18n.t("state_file.questions.nj_retirement_income_source.edit.option_other")
        click_on I18n.t("general.continue")

        expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
        within "#retirement-income-source" do
          expect(page).to have_text I18n.t("state_file.questions.nj_review.edit.retirement_income_source_other")
        end
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
