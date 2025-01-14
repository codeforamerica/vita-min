require "rails_helper"
require 'axe-capybara'
require 'axe-rspec'

RSpec.feature "Completing a state file intake", active_job: true do
  include MockTwilio
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  context "NJ", :flow_explorer_screenshot, js: true do

    def advance_to_start_of_intake(df_persona_name, check_a11y: false, expect_income_review: true)
      visit "/"
      click_on "Start Test NJ"

      expect(page).to have_text I18n.t("state_file.landing_page.edit.nj.title")
      expect(page).to be_axe_clean if check_a11y
      click_on "Get Started", id: "firstCta"

      expect(page).to be_axe_clean if check_a11y
      continue

      expect(page).to be_axe_clean if check_a11y
      step_through_initial_authentication(contact_preference: :email)
      expect(page).to be_axe_clean if check_a11y

      check "Email"
      check "Text message"
      fill_in "Your phone number", with: "+12025551212"
      expect(page).to be_axe_clean if check_a11y
      click_on "Continue"

      expect(page).to have_text I18n.t('state_file.questions.sms_terms.edit.title')
      expect(page).to be_axe_clean if check_a11y
      click_on I18n.t("general.accept")

      expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
      expect(page).to be_axe_clean if check_a11y
      click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

      step_through_df_data_transfer("Transfer #{df_persona_name}")

      if expect_income_review
        expect(page).to have_text I18n.t("state_file.questions.income_review.edit.title")
        expect(page).to be_axe_clean if check_a11y
        continue
      end
    end

    def advance_health_insurance_eligibility
      expect(page).to have_text I18n.t("state_file.questions.nj_eligibility_health_insurance.edit.title")
      choose I18n.t("general.affirmative")
      continue
    end

    def advance_county_and_municipality(county = "Atlantic", municipality = "Atlantic City")
      select county
      continue

      select municipality
      continue
    end

    def advance_disabled_exemption(selection = false)
      # disabled exemption
      page.all(:css, '.white-group').each do |group|
        within group do
          choose selection ? I18n.t('general.affirmative') : I18n.t('general.negative')
        end
      end
      continue
    end

    def advance_veterans_exemption(selection = false)
      # veterans exemption
      page.all(:css, '.white-group').each do |group|
        within group do
          choose selection ? I18n.t('general.affirmative') : I18n.t('general.negative')
        end
      end
      continue
    end

    def advance_college_dependents(selection = false)
      page.all(:css, '.white-group').each do |group|
        within group do
          next unless selection
          check I18n.t('state_file.questions.nj_college_dependents_exemption.edit.dependent_attends_accredited_program')
          check I18n.t('state_file.questions.nj_college_dependents_exemption.edit.dependent_enrolled_full_time')
          check I18n.t('state_file.questions.nj_college_dependents_exemption.edit.dependent_five_months_in_college')
          check I18n.t('state_file.questions.nj_college_dependents_exemption.edit.filer_pays_tuition_books')
        end
      end
      continue
    end

    def advance_medical_expenses(amount: 1000)
      fill_in I18n.t('state_file.questions.nj_medical_expenses.edit.label', filing_year: filing_year), with: amount
      continue
    end

    def continue
      click_on I18n.t("general.continue")
    end

    def choose_household_rent_own(household_rent_own)
      case household_rent_own
      when "homeowner", "tenant", "both", "neither"
        choose strip_html_tags(I18n.t("state_file.questions.nj_household_rent_own.edit.#{household_rent_own}_html"))
      else
        throw "not a valid choice"
      end
      continue
    end

    def select_homeowner_eligibility(checkboxes, continue_to_next: true)
      expect(page).to have_text I18n.t("state_file.questions.nj_homeowner_eligibility.edit.title", filing_year: filing_year)
      checkboxes.each do |checkbox|
        check I18n.t("state_file.questions.nj_homeowner_eligibility.edit.#{checkbox}")
      end
      if continue_to_next
        continue
      end
    end

    def select_tenant_eligibility(checkboxes, continue_to_next: true)
      expect(page).to have_text I18n.t("state_file.questions.nj_tenant_eligibility.edit.title", filing_year: filing_year)
      checkboxes.each do |checkbox|
        check I18n.t("state_file.questions.nj_tenant_eligibility.edit.#{checkbox}")
      end
      if continue_to_next
        continue
      end
    end

    def expect_all_homeowner_checkboxes_state(checkboxes, expected_state)
      expect(page).to have_text I18n.t("state_file.questions.nj_homeowner_eligibility.edit.title", filing_year: filing_year)
      checkboxes.each do |checkbox|
        expect(page).to have_field(I18n.t("state_file.questions.nj_homeowner_eligibility.edit.#{checkbox}"), checked: expected_state)
      end
    end

    def expect_all_tenant_checkboxes_state(checkboxes, expected_state)
      expect(page).to have_text I18n.t("state_file.questions.nj_tenant_eligibility.edit.title", filing_year: filing_year)
      checkboxes.each do |checkbox|
        expect(page).to have_field(I18n.t("state_file.questions.nj_tenant_eligibility.edit.#{checkbox}"), checked: expected_state)
      end
    end

    def fill_property_tax_paid(amount, municipality = "Atlantic City")
      expect(page).to have_text I18n.t("state_file.questions.nj_homeowner_property_tax.edit.title", filing_year: filing_year, municipality: municipality)
      fill_in strip_html_tags(I18n.t('state_file.questions.nj_homeowner_property_tax.edit.label_html', filing_year: filing_year)), with: amount
      continue
    end

    def fill_rent_paid(amount)
      expect(page).to have_text I18n.t("state_file.questions.nj_tenant_rent_paid.edit.title", filing_year: filing_year)
      fill_in strip_html_tags(I18n.t('state_file.questions.nj_tenant_rent_paid.edit.label_html', filing_year: filing_year)), with: amount
      continue
    end

    def expect_page_after_property_tax
      expect(page).to have_text I18n.t("state_file.questions.nj_sales_use_tax.edit.title", filing_year: filing_year)
    end

    def expect_ineligible_page(property, reason)
      valid_property_values = ["on_home", "on_rental", nil]
      valid_reasons = ["multi_unit_conditions", "property_taxes", "neither"]
      throw "not a valid property value: #{property}" unless valid_property_values.include?(property)
      throw "not a valid reason value: #{reason}" unless valid_reasons.include?(reason)

      reason_text = I18n.t("state_file.questions.nj_ineligible_property_tax.edit.reason_#{reason}", filing_year: MultiTenantService.statefile.current_tax_year)
      property_text = property.present? ? I18n.t("state_file.questions.nj_ineligible_property_tax.edit.#{property}") : nil
      expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.nj_ineligible_property_tax.edit.title_html", property: property_text)).strip
      expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.nj_ineligible_property_tax.edit.reason_html", reason: reason_text))
      continue
    end

    def advance_to_property_tax_page(skip_health_insurance_eligibility: false)
      advance_health_insurance_eligibility unless skip_health_insurance_eligibility
      advance_county_and_municipality
      if has_text? I18n.t("state_file.questions.nj_disabled_exemption.edit.title")
        advance_disabled_exemption
      end
      advance_veterans_exemption
      if has_text? I18n.t("state_file.questions.nj_college_dependents_exemption.edit.title")
        advance_college_dependents
      end
      advance_medical_expenses
    end

    it "advances past the loading screen by listening for an actioncable broadcast", required_schema: "nj" do
      advance_to_start_of_intake("O neal walker catchall mfj", check_a11y: true, expect_income_review: true)
      
      expect(page).to be_axe_clean
      advance_health_insurance_eligibility
      
      expect(page).to be_axe_clean
      advance_county_and_municipality
      
      expect(page).to be_axe_clean
      advance_disabled_exemption
      
      expect(page).to be_axe_clean
      advance_veterans_exemption
      
      expect(page).to be_axe_clean
      advance_college_dependents
      
      expect(page).to be_axe_clean
      advance_medical_expenses
      
      expect(page).to be_axe_clean
      choose_household_rent_own("neither")
      expect(page).to be_axe_clean
      continue

      # sales use tax
      expect(page).to be_axe_clean
      choose I18n.t('general.negative')
      continue

      # estimated tax payments
      expect(page).to be_axe_clean
      fill_in I18n.t('state_file.questions.nj_estimated_tax_payments.edit.label', filing_year: MultiTenantService.statefile.current_tax_year), with: 1000
      continue

      # Driver License
      expect(page).to be_axe_clean
      choose I18n.t('state_file.questions.nj_primary_state_id.nj_primary.no_id')
      continue
      choose I18n.t('state_file.questions.nj_spouse_state_id.nj_spouse.no_id')
      continue

      # Review
      expect(page).to have_text I18n.t("state_file.questions.shared.abstract_review_header.title")
      expect(page).to be_axe_clean.within "main"

      groups = page.all(:css, '.white-group').count
      h2s = page.all(:css, 'h2').count
      expect(groups).to eq(h2s - 2)
      # total should be h2s -1 to account for the h2 reveal button
      # there's also an extra h2 in the veteran exemption box

      edit_buttons = page.all(:css, '.white-group a')
      edit_buttons_count = edit_buttons.count
      edit_buttons_with_sr_only_text = page.all(:css, '.white-group a span.sr-only').count
      expect(edit_buttons_count).to eq(edit_buttons_with_sr_only_text)

      edit_buttons_text = edit_buttons.map(&:text)
      edit_buttons_unique_text_count = edit_buttons_text.uniq.count
      expect(edit_buttons_unique_text_count).to eq(edit_buttons_count)

      click_on I18n.t("state_file.questions.nj_review.edit.reveal.header")
      amounts_in_calculation_details = page.all(:xpath, '//*[contains(@class,"main-content-inner")]/section[last()]//p[contains(text(),"$")]')
      expect(amounts_in_calculation_details.count).to eq(19)
      expect(page).to be_axe_clean
      continue

      # Tax Refund
      expect(page).to be_axe_clean
      expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.tax_refund.edit.title_html", refund_amount: 4619, state_name: "New Jersey"))
      choose I18n.t('state_file.questions.tax_refund.edit.mail')
      continue

      # Gubernatorial elections fund
      expect(page).to be_axe_clean
      within_fieldset(I18n.t('state_file.questions.nj_gubernatorial_elections.edit.primary_contribute')) do 
        choose I18n.t('general.affirmative')
      end
      within_fieldset(I18n.t('state_file.questions.nj_gubernatorial_elections.edit.spouse_contribute')) do 
        choose I18n.t('general.affirmative')
      end
      continue

      expect(page).to be_axe_clean
      check I18n.t('state_file.questions.esign_declaration.edit.primary_esign')
      check I18n.t('state_file.questions.esign_declaration.edit.spouse_esign')
      click_on I18n.t('state_file.questions.esign_declaration.edit.submit')
      
      expect(page).to be_axe_clean
      expect(page).to have_text I18n.t("state_file.questions.submission_confirmation.edit.title", filing_year: 2024, state_name: "New Jersey")      
    end

    it "handles property tax neither flow", required_schema: "nj" do
      advance_to_start_of_intake("Zeus one dep")
      advance_to_property_tax_page
      choose_household_rent_own("neither")
      expect_ineligible_page(nil, "neither")
      expect_page_after_property_tax
    end

    context "when tenant" do
      it "handles property tax eligible tenant flow", required_schema: "nj" do
        advance_to_start_of_intake("Zeus one dep")
        advance_to_property_tax_page
        choose_household_rent_own("tenant")
        select_tenant_eligibility(["tenant_home_subject_to_property_taxes"])
        fill_rent_paid(10000)
        expect_page_after_property_tax
      end

      it "handles property tax ineligible tenant flow", required_schema: "nj" do
        advance_to_start_of_intake("Zeus one dep")
        advance_to_property_tax_page
        choose_household_rent_own("tenant")
        select_tenant_eligibility([])
        expect_ineligible_page("on_rental", "property_taxes")
        expect_page_after_property_tax
      end

      it "handles tenant none of the above checkbox", required_schema: "nj" do
        advance_to_start_of_intake("Lauryn mfs")
        advance_to_property_tax_page
        choose_household_rent_own("tenant")
        all_checkboxes = ["tenant_home_subject_to_property_taxes", "tenant_building_multi_unit", "tenant_more_than_one_main_home_in_nj", "tenant_shared_rent_not_spouse", "tenant_same_home_spouse", "tenant_access_kitchen_bath"]
        conditional_checkbox = "state_file.questions.nj_tenant_eligibility.edit.tenant_access_kitchen_bath"
        none_checkbox = "general.none_of_these"
        select_tenant_eligibility(all_checkboxes, continue_to_next: false)
        expect_all_tenant_checkboxes_state(all_checkboxes, true)
        check I18n.t(none_checkbox)
        expect(page).not_to have_text(I18n.t(conditional_checkbox))
        expect_all_tenant_checkboxes_state(all_checkboxes[0...-1], false)
        check I18n.t("state_file.questions.nj_tenant_eligibility.edit.tenant_building_multi_unit")
        expect(page).to have_field(I18n.t(conditional_checkbox), checked: false)
        expect(page).to have_field(I18n.t(none_checkbox), checked: false)
        continue
        expect_ineligible_page("on_rental", "property_taxes")
        expect_page_after_property_tax
      end
    end

    context "when homeowner" do
      it "handles property tax eligible homeowner flow", required_schema: "nj" do
        advance_to_start_of_intake("Zeus one dep")
        advance_to_property_tax_page
        choose_household_rent_own("homeowner")
        select_homeowner_eligibility(["homeowner_home_subject_to_property_taxes"])
        fill_property_tax_paid(10000)
        expect_page_after_property_tax
      end

      it "handles property tax ineligible homeowner flow", required_schema: "nj" do
        advance_to_start_of_intake("Zeus one dep")
        advance_to_property_tax_page
        choose_household_rent_own("homeowner")
        select_homeowner_eligibility([])
        expect_ineligible_page("on_home", "property_taxes")
        expect_page_after_property_tax
      end

      it "handles homeowner none of the above checkbox", required_schema: "nj" do
        advance_to_start_of_intake("Lauryn mfs")
        advance_to_property_tax_page
        choose_household_rent_own("homeowner")
        all_checkboxes = ["homeowner_home_subject_to_property_taxes", "homeowner_more_than_one_main_home_in_nj", "homeowner_shared_ownership_not_spouse", "homeowner_same_home_spouse", "homeowner_main_home_multi_unit", "homeowner_main_home_multi_unit_max_four_one_commercial"]
        conditional_checkbox = "state_file.questions.nj_homeowner_eligibility.edit.homeowner_main_home_multi_unit_max_four_one_commercial"
        none_checkbox = "general.none_of_these"
        select_homeowner_eligibility(all_checkboxes, continue_to_next: false)
        expect_all_homeowner_checkboxes_state(all_checkboxes, true)
        check I18n.t(none_checkbox)
        expect(page).not_to have_text(I18n.t(conditional_checkbox))
        expect_all_homeowner_checkboxes_state(all_checkboxes[0...-1], false)
        check I18n.t("state_file.questions.nj_homeowner_eligibility.edit.homeowner_main_home_multi_unit")
        expect(page).to have_field(I18n.t(conditional_checkbox), checked: false)
        expect(page).to have_field(I18n.t(none_checkbox), checked: false)
        continue
        expect_ineligible_page("on_home", "property_taxes")
        expect_page_after_property_tax
      end
    end

    context "when both homeowner and tenant" do
      it "handles property tax eligible both homeowner & tenant flow", required_schema: "nj" do
        advance_to_start_of_intake("Zeus one dep")
        advance_to_property_tax_page
        choose_household_rent_own("both")
        select_homeowner_eligibility(["homeowner_home_subject_to_property_taxes"])
        fill_property_tax_paid(10000)
        select_tenant_eligibility(["tenant_home_subject_to_property_taxes"])
        fill_rent_paid(10000)
        expect_page_after_property_tax
      end

      it "handles property tax both flow - eligible homeowner & ineligible tenant", required_schema: "nj" do
        advance_to_start_of_intake("Zeus one dep")
        advance_to_property_tax_page
        choose_household_rent_own("both")
        select_homeowner_eligibility(["homeowner_home_subject_to_property_taxes"])
        fill_property_tax_paid(10000)
        select_tenant_eligibility([])
        expect_ineligible_page("on_rental", "property_taxes")
        expect_page_after_property_tax
      end

      it "handles property tax both flow - ineligible homeowner & eligible tenant", required_schema: "nj" do
        advance_to_start_of_intake("Zeus one dep")
        advance_to_property_tax_page
        choose_household_rent_own("both")
        select_homeowner_eligibility([])
        expect_ineligible_page("on_home", "property_taxes")
        select_tenant_eligibility(["tenant_home_subject_to_property_taxes"])
        fill_rent_paid(10000)
        expect_page_after_property_tax
      end
    end

    context "when low income but meets exception" do
      it "handles property tax flow - eligible homeowner", required_schema: "nj" do
        advance_to_start_of_intake("Minimal", expect_income_review: false) # low income
        advance_county_and_municipality
        advance_disabled_exemption(true) # disabled exemption
        advance_veterans_exemption
        advance_medical_expenses
        choose_household_rent_own("homeowner")
        select_homeowner_eligibility(["homeowner_home_subject_to_property_taxes"])
        # skips property tax paid page
        expect_page_after_property_tax
      end

      it "handles property tax flow - eligible tenant", required_schema: "nj" do
        advance_to_start_of_intake("Minimal", expect_income_review: false) # low income
        advance_county_and_municipality
        advance_disabled_exemption(true) # disabled exemption
        advance_veterans_exemption
        advance_medical_expenses
        choose_household_rent_own("tenant")
        select_tenant_eligibility(["tenant_home_subject_to_property_taxes"])
        # skips rent paid page
        expect_page_after_property_tax
      end

      it "handles property tax flow - when both and eligible homeowner", required_schema: "nj" do
        advance_to_start_of_intake("Minimal", expect_income_review: false) # low income
        advance_county_and_municipality
        advance_disabled_exemption(true) # disabled exemption
        advance_veterans_exemption
        advance_medical_expenses
        choose_household_rent_own("both")
        select_homeowner_eligibility(["homeowner_home_subject_to_property_taxes"])
        # skips property tax paid page
        # skips tenant eligibility page (because they only need to qualify for one type of eligibility)
        expect_page_after_property_tax
      end

      it "handles property tax both flow - ineligible homeowner and eligible tenant", required_schema: "nj" do
        advance_to_start_of_intake("Minimal", expect_income_review: false) # low income
        advance_county_and_municipality
        advance_disabled_exemption(true) # disabled exemption
        advance_veterans_exemption
        advance_medical_expenses
        choose_household_rent_own("both")
        select_homeowner_eligibility([])
        expect_ineligible_page("on_home", "property_taxes")
        select_tenant_eligibility(["tenant_home_subject_to_property_taxes"])
        # skips rent paid page
        expect_page_after_property_tax
      end
    end
  end
end