module CtcIntakeFeatureHelper
  def fill_in_can_use_ctc(filing_status: "married_filing_jointly", home_location: "fifty_states", claim_eitc: false)
    ctc_current_tax_year = MultiTenantService.new(:ctc).current_tax_year
    married_filing_jointly = filing_status == "married_filing_jointly"
    # =========== BASIC INFO ===========
    if home_location == "puerto_rico"
      visit "/en/puertorico"
      click_on I18n.t("general.get_started"), id: "firstCta"
      expect(page).to have_content I18n.t('views.ctc_pages.puerto_rico_overview.do_my_children_qualify_reveal.title')
      click_on I18n.t('general.continue')
    else
      visit "/en/questions/overview"
      expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
      click_on I18n.t('general.continue')
    end

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.main_home.title', current_tax_year: ctc_current_tax_year))
    choose I18n.t('views.ctc.questions.main_home.options.foreign_address')
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.use_gyr.title'))
    click_on I18n.t('general.back')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.main_home.title', current_tax_year: ctc_current_tax_year))
    choose I18n.t("views.ctc.questions.main_home.options.#{home_location}")
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filing_status.title', current_tax_year: ctc_current_tax_year))
    if married_filing_jointly
      click_on I18n.t('general.affirmative')
    else
      click_on I18n.t('general.negative')
    end

    expect(page).to have_text(I18n.t("views.ctc.questions.income_qualifier.subtitle"))
    click_on I18n.t('general.affirmative')

    expect(page).to have_selector(".toolbar", text: "GetCTC")
    within "h1" do
      if married_filing_jointly
        expect(page.source).to include(I18n.t('views.ctc.questions.income.title.other', current_tax_year: ctc_current_tax_year))
      else
        expect(page.source).to include(I18n.t('views.ctc.questions.income.title.one', current_tax_year: ctc_current_tax_year))
      end
    end
    click_on I18n.t('general.continue')

    title_key = home_location == "puerto_rico" ? "puerto_rico.title" : "title_eitc"
    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.file_full_return.#{title_key}"))
    click_on I18n.t("views.ctc.questions.file_full_return.#{home_location == "puerto_rico" ? "puerto_rico." : ""}simplified_btn")
    if home_location != "puerto_rico"
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.claim_eitc.title'))
      click_on claim_eitc ? I18n.t("views.ctc.questions.claim_eitc.buttons.claim") : I18n.t('views.ctc.questions.claim_eitc.buttons.dont_claim')
    end
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.restrictions.title'))
    click_on I18n.t('views.ctc.questions.restrictions.cannot_use_ctc')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.use_gyr.title'))
    click_on I18n.t('general.back')
    click_on I18n.t('general.continue')
  end

  def fill_in_eligibility(home_location: "fifty_states")
    ctc_current_tax_year = MultiTenantService.new(:ctc).current_tax_year
    # =========== ELIGIBILITY ===========
    if home_location == "puerto_rico"
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.already_filed.puerto_rico.title', current_tax_year: ctc_current_tax_year))
    else
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.already_filed.title', current_tax_year: ctc_current_tax_year))
    end
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.life_situations.title', current_tax_year: ctc_current_tax_year))
    click_on I18n.t('general.negative')
  end

  def fill_in_basic_info(home_location: "fifty_states", birthdate: DateTime.new(1996, 8, 24))
    ctc_current_tax_year = MultiTenantService.new(:ctc).current_tax_year
    ctc_prior_tax_year = MultiTenantService.new(:ctc).prior_tax_year

    # =========== BASIC INFO ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.legal_consent.title'))
    fill_in I18n.t('views.ctc.questions.legal_consent.first_name'), with: "Gary"
    fill_in I18n.t('views.ctc.questions.legal_consent.middle_initial'), with: "H"
    fill_in I18n.t('views.ctc.questions.legal_consent.last_name'), with: "Mango"
    select "III", from: I18n.t('views.ctc.questions.legal_consent.suffix')
    fill_in "ctc_legal_consent_form_primary_birth_date_month", with: birthdate.month
    fill_in "ctc_legal_consent_form_primary_birth_date_day", with: birthdate.day
    fill_in "ctc_legal_consent_form_primary_birth_date_year", with: birthdate.year
    fill_in I18n.t('views.ctc.questions.legal_consent.ssn'), with: "111-22-8888"
    fill_in I18n.t('views.ctc.questions.legal_consent.ssn_confirmation'), with: "111-22-8888"
    fill_in I18n.t('views.ctc.questions.legal_consent.sms_phone_number'), with: "831-234-5678"
    check I18n.t('views.ctc.questions.legal_consent.primary_active_armed_forces', current_tax_year: ctc_current_tax_year)
    check "agree_to_privacy_policy"
    click_on I18n.t('general.continue')

    if home_location == "puerto_rico"
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filed_prior_tax_year.puerto_rico.title', prior_tax_year: ctc_prior_tax_year))
      choose I18n.t('views.ctc.questions.filed_prior_tax_year.puerto_rico.did_not_file', prior_tax_year: ctc_prior_tax_year)
    else
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filed_prior_tax_year.title', prior_tax_year: ctc_prior_tax_year))
      choose I18n.t('views.ctc.questions.filed_prior_tax_year.did_not_file', prior_tax_year: ctc_prior_tax_year)
    end
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.contact_preference.title'))
    click_on I18n.t('views.ctc.questions.contact_preference.email')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.email_address.title'))
    fill_in I18n.t('views.questions.email_address.email_address'), with: "mango@example.com"
    fill_in I18n.t('views.questions.email_address.email_address_confirmation'), with: "mango@example.com"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("p", text: I18n.t('views.ctc.questions.verification.body').strip)

    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    code = mail.html_part.body.to_s.match(/(\d{6})[.]/)[1]

    fill_in I18n.t('views.ctc.questions.verification.verification_code_label'), with: "000001"
    click_on I18n.t("views.ctc.questions.verification.verify")
    expect(page).to have_content(I18n.t('views.ctc.questions.verification.error_message'))

    fill_in I18n.t('views.ctc.questions.verification.verification_code_label'), with: code
    click_on I18n.t("views.ctc.questions.verification.verify")
  end

  def fill_in_spouse_info(home_location: nil, birthdate: DateTime.new(1995, 1, 11))
    # =========== SPOUSE INFO ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.spouse_info.title'))
    fill_in I18n.t('views.ctc.questions.spouse_info.spouse_first_name'), with: "Peter"
    fill_in I18n.t('views.ctc.questions.spouse_info.spouse_middle_initial'), with: "P"
    fill_in I18n.t('views.ctc.questions.spouse_info.spouse_last_name'), with: "Pepper"
    fill_in "ctc_spouse_info_form[spouse_birth_date_month]", with: birthdate.month
    fill_in "ctc_spouse_info_form[spouse_birth_date_day]", with: birthdate.day
    fill_in "ctc_spouse_info_form[spouse_birth_date_year]", with: birthdate.year
    select I18n.t('general.tin.ssn')
    fill_in I18n.t('views.ctc.questions.spouse_info.spouse_ssn_itin'), with: "222-33-4444"
    fill_in I18n.t('views.ctc.questions.spouse_info.spouse_ssn_itin_confirmation'), with: "222-33-4444"
    check I18n.t('views.ctc.questions.spouse_info.spouse_was_blind', current_tax_year: MultiTenantService.new(:ctc).current_tax_year)
    click_on I18n.t('views.ctc.questions.spouse_info.save_button')
    expect(page).not_to have_text(I18n.t('views.ctc.questions.spouse_info.remove_button'))
    if home_location == "puerto_rico"
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.spouse_filed_prior_tax_year.puerto_rico.title', prior_tax_year: prior_tax_year, spouse_first_name: "Peter"))
      choose I18n.t('views.ctc.questions.spouse_filed_prior_tax_year.puerto_rico.did_not_file', spouse_first_name: "Peter", prior_tax_year: prior_tax_year)
    else
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.spouse_filed_prior_tax_year.title', prior_tax_year: prior_tax_year, spouse_first_name: "Peter"))
      choose I18n.t('views.ctc.questions.spouse_filed_prior_tax_year.did_not_file', prior_tax_year: prior_tax_year)
    end
    click_on I18n.t('general.continue')

    expect(page).to have_text(I18n.t('views.ctc.questions.spouse_review.title'))
    expect(page).to have_text("Peter Pepper")
    expect(page).to have_text(I18n.t('views.ctc.questions.spouse_review.spouse_birthday', dob: birthdate.strftime("%-m/%-d/%Y")))
    expect(page).to have_text(I18n.t('views.ctc.questions.spouse_review.spouse_ssn', ssn: "4444"))
    click_on I18n.t('general.edit').downcase

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.spouse_info.title'))
    click_on I18n.t('views.ctc.questions.spouse_info.remove_button')

    within "h1" do
      expect(strip_inner_newlines(page.text)).to eq(strip_inner_newlines(strip_html_tags(I18n.t("views.ctc.questions.remove_spouse.title_html", spouse_name: "Peter Pepper"))))
    end

    click_on I18n.t('views.ctc.questions.remove_spouse.nevermind_button')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.spouse_review.title'))
    click_on I18n.t('general.continue')
  end

  def fill_in_dependent_info(dependent_birth_year)
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.info.title'))
    fill_in I18n.t('views.ctc.questions.dependents.info.first_name'), with: "Jessie"
    fill_in I18n.t('views.ctc.questions.dependents.info.middle_initial'), with: "M"
    fill_in I18n.t('views.ctc.questions.dependents.info.last_name'), with: "Pepper"
    fill_in "ctc_dependents_info_form[birth_date_month]", with: "11"
    fill_in "ctc_dependents_info_form[birth_date_day]", with: "01"
    fill_in "ctc_dependents_info_form[birth_date_year]", with: dependent_birth_year
    select "Social Security Number (SSN)"
    fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin', name: "Jessie"), with: "222-33-4445"
    fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin_confirmation', name: "Jessie"), with: "222-33-4445"
  end

  def fill_in_qualifying_child_age_5
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.info.title'))
    fill_in I18n.t('views.ctc.questions.dependents.info.first_name'), with: "Jessie"
    fill_in I18n.t('views.ctc.questions.dependents.info.middle_initial'), with: "M"
    fill_in I18n.t('views.ctc.questions.dependents.info.last_name'), with: "Pepper"
    fill_in "ctc_dependents_info_form[birth_date_month]", with: "11"
    fill_in "ctc_dependents_info_form[birth_date_day]", with: "01"
    fill_in "ctc_dependents_info_form[birth_date_year]", with: 5.years.ago
    select "Social Security Number (SSN)"
    select I18n.t('general.dependent_relationships.daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
    fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin', name: "Jessie"), with: "222-33-4445"
    fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin_confirmation', name: "Jessie"), with: "222-33-4445"
    click_on "Continue"

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_expenses.title', name: 'Jessie', current_tax_year: MultiTenantService.new(:ctc).current_tax_year))
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_residence.title', name: 'Jessie', current_tax_year: current_tax_year))
    select I18n.t("views.ctc.questions.dependents.child_residence.select_options.seven")
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_can_be_claimed_by_other.title', name: 'Jessie'))
    click_on I18n.t('general.affirmative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title'))
  end

  def fill_in_dependents(head_of_household: false)
    # =========== DEPENDENTS ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.had_dependents.title', current_tax_year: current_tax_year))
    click_on I18n.t('views.ctc.questions.had_dependents.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.no_dependents.title'))
    click_on I18n.t('general.back')
    click_on I18n.t('views.ctc.questions.had_dependents.add')

    dependent_birth_year = 5.years.ago.year

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.info.title'))
    fill_in I18n.t('views.ctc.questions.dependents.info.first_name'), with: "Jessie"
    fill_in I18n.t('views.ctc.questions.dependents.info.middle_initial'), with: "M"
    fill_in I18n.t('views.ctc.questions.dependents.info.last_name'), with: "Pepper"
    fill_in "ctc_dependents_info_form[birth_date_month]", with: "01"
    fill_in "ctc_dependents_info_form[birth_date_day]", with: "11"
    fill_in "ctc_dependents_info_form[birth_date_year]", with: dependent_birth_year
    select I18n.t('general.dependent_relationships.daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
    fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin'), with: "222-33-4445"
    fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin_confirmation'), with: "222-33-4445"

    click_on I18n.t('general.continue')

    # Skips qualifiers page because the dependent is only 5

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_expenses.title', name: 'Jessie', current_tax_year: MultiTenantService.new(:ctc).current_tax_year))
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_residence.title', name: 'Jessie', current_tax_year: current_tax_year))
    select I18n.t("views.ctc.questions.dependents.child_residence.select_options.seven")
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_can_be_claimed_by_other.title', name: 'Jessie'))
    click_on I18n.t('general.affirmative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title'))
    expect(page).to have_content("Jessie M Pepper")
    expect(page).to have_selector("div", text: "#{I18n.t('views.ctc.questions.confirm_dependents.birthday')}: 1/11/#{dependent_birth_year}")

    click_on "Add another person"

    dependent_birth_year = 18.years.ago.year

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.info.title'))
    fill_in I18n.t('views.ctc.questions.dependents.info.first_name'), with: "Red"
    fill_in I18n.t('views.ctc.questions.dependents.info.middle_initial'), with: "Hot"
    fill_in I18n.t('views.ctc.questions.dependents.info.last_name'), with: "Pepper"
    fill_in "ctc_dependents_info_form[birth_date_month]", with: "01"
    fill_in "ctc_dependents_info_form[birth_date_day]", with: "11"
    fill_in "ctc_dependents_info_form[birth_date_year]", with: dependent_birth_year
    select I18n.t('general.dependent_relationships.daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
    fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin'), with: "222-33-4445"
    fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin_confirmation'), with: "222-33-4445"

    click_on I18n.t('general.continue')

    # Skips qualifies page because the dependent is younger than 19

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_expenses.title', name: 'Red', current_tax_year: MultiTenantService.new(:ctc).current_tax_year))
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_residence.title', name: 'Red', current_tax_year: current_tax_year))
    select I18n.t("views.ctc.questions.dependents.child_residence.select_options.seven")
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_can_be_claimed_by_other.title', name: 'Red'))
    click_on I18n.t('general.affirmative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title'))
    expect(page).to have_content("Red Hot Pepper")
    expect(page).to have_selector("div", text: "#{I18n.t('views.ctc.questions.confirm_dependents.birthday')}: 1/11/#{dependent_birth_year}")

    within "#dependent_#{Dependent.last.id}" do
      expect(page).to have_css("img[src*='/assets/icons/green-checkmark-circle']")
      click_on "edit"
    end

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.dependent_info.title", name: "Red"))
    click_on I18n.t("views.ctc.questions.dependents.tin.remove_person")
    expect(page).to have_text I18n.t("views.ctc.questions.dependents.remove_dependent.title", dependent_name: "Red")
    click_on I18n.t("views.ctc.questions.dependents.remove_dependent.remove_button")

    expect(page).to have_selector("h1", text: "Let’s confirm!")
    expect(page).not_to have_text "Red Hot Pepper"

    click_on I18n.t('views.ctc.questions.confirm_dependents.add_a_dependent')

    dependent_birth_year = 40.years.ago.year

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.info.title'))
    fill_in I18n.t('views.ctc.questions.dependents.info.first_name'), with: "Sam"
    fill_in I18n.t('views.ctc.questions.dependents.info.middle_initial'), with: ""
    fill_in I18n.t('views.ctc.questions.dependents.info.last_name'), with: "NotQualified"
    fill_in "ctc_dependents_info_form[birth_date_month]", with: "01"
    fill_in "ctc_dependents_info_form[birth_date_day]", with: "11"
    fill_in "ctc_dependents_info_form[birth_date_year]", with: dependent_birth_year
    select I18n.t('general.dependent_relationships.uncle'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
    fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin'), with: "222-33-4446"
    fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin_confirmation'), with: "222-33-4446"
    click_on I18n.t("general.continue")
    expect(page).to have_text "Did you pay more than half of Sam's living expenses for 2021?"
    click_on "No"

    expect(page).to have_text "You can not claim benefits for Sam. Would you like to add anyone else?"
    click_on "No"

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title'))
    expect(page).to have_content("Sam NotQualified")
    expect(page).to have_selector("div", text: "#{I18n.t('views.ctc.questions.confirm_dependents.birthday')}: 1/11/#{dependent_birth_year}")
    within "#dependent_#{Dependent.last.id}" do
      expect(page).not_to have_css("img[src*='/assets/icons/green-checkmark-circle']")
    end

    click_on I18n.t('views.ctc.questions.confirm_dependents.done_adding')
  end

  def fill_in_no_dependents
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.had_dependents.title', current_tax_year: current_tax_year))
    click_on I18n.t('views.ctc.questions.had_dependents.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.no_dependents.title'))
    click_on I18n.t('general.continue')
    expect(page).to have_text(I18n.t('views.ctc.questions.no_dependents_advance_ctc_payments.title', current_tax_year: current_tax_year))
    click_on I18n.t('general.negative')
  end

  def fill_in_w2(employee_name, filing_status: 'single', wages: 123.45, delete_instead_of_submit: false, box_12a: "F")
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.w2s.title'))
    click_on I18n.t('views.ctc.questions.w2s.add')

    if filing_status == 'single'
      expect(page).to have_text(I18n.t('views.ctc.questions.w2s.employee_info.title', count: 1, name: employee_name))
    else
      expect(page).to have_text(I18n.t('views.ctc.questions.w2s.employee_info.title', count: 2))
      select employee_name, from: I18n.t('views.ctc.questions.w2s.employee_info.employee_legal_name')
    end
    fill_in I18n.t('views.ctc.questions.w2s.employee_info.employee_street_address'), with: '123 Cool St'
    fill_in I18n.t('views.ctc.questions.w2s.employee_info.employee_city'), with: 'City Town'
    select "California", from: I18n.t('views.ctc.questions.w2s.employee_info.employee_state')
    fill_in I18n.t('views.ctc.questions.w2s.employee_info.employee_zip_code'), with: '94110'
    click_on I18n.t('general.continue')

    expect(page).to have_text(I18n.t('views.ctc.questions.w2s.wages_info.title', name: employee_name))
    fill_in I18n.t('views.ctc.questions.w2s.wages_info.wages_amount'), with: wages
    fill_in I18n.t('views.ctc.questions.w2s.wages_info.federal_income_tax_withheld'), with: '12.01'
    fill_in I18n.t('views.ctc.questions.w2s.wages_info.box3_social_security_wages'), with: 1.40
    fill_in I18n.t('views.ctc.questions.w2s.wages_info.box4_social_security_tax_withheld'), with: 123.30
    fill_in I18n.t('views.ctc.questions.w2s.wages_info.box5_medicare_wages_and_tip_amount'), with: 5.12
    fill_in I18n.t('views.ctc.questions.w2s.wages_info.box6_medicare_tax_withheld'), with: 12.67
    fill_in I18n.t('views.ctc.questions.w2s.wages_info.box7_social_security_tips_amount'), with: 27.32

    click_on I18n.t('general.continue')

    expect(page).to have_text(I18n.t('views.ctc.questions.w2s.employer_info.title', name: employee_name))
    fill_in I18n.t('views.ctc.questions.w2s.employer_info.employer_ein'), with: '123112222'
    fill_in I18n.t('views.ctc.questions.w2s.employer_info.employer_name'), with: 'lumen inc'
    fill_in I18n.t('views.ctc.questions.w2s.employer_info.employer_street_address'), with: '123 Easy St'
    fill_in I18n.t('views.ctc.questions.w2s.employer_info.employer_city'), with: 'Citytown'
    select "California", from: I18n.t('views.ctc.questions.w2s.employer_info.employer_state')
    fill_in I18n.t('views.ctc.questions.w2s.employer_info.employer_zip_code'), with: '94105'
    fill_in I18n.t('views.ctc.questions.w2s.employer_info.box_d_control_number'), with: '12345678'
    click_on I18n.t('general.continue')

    expect(page).to have_text(I18n.t('views.ctc.questions.w2s.misc_info.title', name: employee_name))
    fill_in I18n.t('views.ctc.questions.w2s.misc_info.box11_nonqualified_plans'), with: '123'
    select box_12a, from: I18n.t("views.ctc.questions.w2s.misc_info.box12a")
    fill_in 'ctc_w2s_misc_info_form_box12a_value', with: "44.50"
    select "E", from: I18n.t("views.ctc.questions.w2s.misc_info.box12b")
    fill_in 'ctc_w2s_misc_info_form_box12b_value', with: "54.50"
    select "C", from: I18n.t("views.ctc.questions.w2s.misc_info.box12c")
    fill_in 'ctc_w2s_misc_info_form_box12c_value', with: "64.50"
    select "D", from: I18n.t("views.ctc.questions.w2s.misc_info.box12d")
    fill_in 'ctc_w2s_misc_info_form_box12d_value', with: "74.50"
    check I18n.t('views.ctc.questions.w2s.misc_info.box13_retirement_plan')

    fill_in 'ctc_w2s_misc_info_form_other_description', with: "abc"
    fill_in 'ctc_w2s_misc_info_form_other_amount', with: "1234"
    select "NY", from: I18n.t("views.ctc.questions.w2s.misc_info.box15_state")
    fill_in 'ctc_w2s_misc_info_form_box15_employer_state_id_number', with: "abcd1234"
    fill_in I18n.t('views.ctc.questions.w2s.misc_info.box16_state_wages'), with: '123'
    fill_in I18n.t('views.ctc.questions.w2s.misc_info.box17_state_income_tax'), with: '20'
    fill_in I18n.t('views.ctc.questions.w2s.misc_info.box18_local_wages'), with: '100'
    fill_in I18n.t('views.ctc.questions.w2s.misc_info.box19_local_income_tax'), with: '21'
    fill_in I18n.t('views.ctc.questions.w2s.misc_info.box20_locality_name'), with: 'banana'


    if delete_instead_of_submit
      click_on I18n.t('views.ctc.questions.w2s.misc_info.remove_this_w2')
    else
      click_on I18n.t('views.ctc.questions.w2s.misc_info.submit')
    end
  end

  def fill_in_advance_child_tax_credit
    # =========== ADVANCE CHILD TAX CREDIT ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.advance_ctc.title', adv_ctc_estimate: 1800))
    expect(page).to have_text("$1800")
    expect(page).to have_text("Jessie M Pepper")
    click_on I18n.t('views.ctc.questions.advance_ctc.no_received_different')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.advance_ctc_amount.title"))
    fill_in I18n.t('views.ctc.questions.advance_ctc_amount.form_title'), with: "1000"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.advance_ctc_received.title"))
    expect(page).to have_text I18n.t('views.ctc.questions.advance_ctc_received.total_adv_ctc', amount: "$1,000")
    expect(page).to have_text "$2,600"
    click_on I18n.t('general.continue')
  end

  def fill_in_recovery_rebate_credit(third_stimulus_amount: "$4,200")
    # =========== RECOVERY REBATE CREDIT ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_payments.title', third_stimulus_amount: third_stimulus_amount))
    click_on I18n.t('views.ctc.questions.stimulus_payments.different_amount')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_three.title'))
    fill_in I18n.t('views.ctc.questions.stimulus_three.how_much'), with: "1800"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_owed.title'))
    click_on I18n.t('general.continue')
  end

  def fill_in_bank_info

    # =========== BANK AND MAILING INFO ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.refund_payment.title'))
    choose I18n.t('views.questions.refund_payment.direct_deposit')
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.portal.bank_account.title'))
    fill_in I18n.t('views.questions.bank_details.bank_name'), with: "Bank of Two Melons"
    choose I18n.t('views.questions.bank_details.account_type.checking')
    check I18n.t('views.ctc.questions.direct_deposit.my_bank_account.label')
    fill_in I18n.t('views.ctc.questions.routing_number.routing_number'), with: "019456124"
    fill_in I18n.t('views.ctc.questions.routing_number.routing_number_confirmation'), with: "019456124"
    fill_in I18n.t('views.ctc.questions.account_number.account_number'), with: "123456789"
    fill_in I18n.t('views.ctc.questions.account_number.account_number_confirmation'), with: "123456789"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_bank_account.title'))
    expect(page).to have_selector("h2", text: I18n.t('views.ctc.questions.confirm_bank_account.bank_information'))
    expect(page).to have_selector("li", text: "Bank of Two Melons")
    expect(page).to have_selector("li", text: "#{I18n.t('general.type')}: Checking")
    expect(page).to have_selector("li", text: "#{I18n.t('general.bank_account.routing_number')}: 019456124")
    expect(page).to have_selector("li", text: "#{I18n.t('general.bank_account.account_number')}: ●●●●●6789")
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.mailing_address.title'))
    fill_in I18n.t('views.questions.mailing_address.street_address'), with: "26 William Street"
    fill_in I18n.t('views.questions.mailing_address.street_address2'), with: "Apt 1234"
    fill_in I18n.t('views.questions.mailing_address.city'), with: "Bel Air"
    select "California", from: I18n.t('views.questions.mailing_address.state')
    fill_in I18n.t('views.questions.mailing_address.zip_code'), with: 90001
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_mailing_address.title"))
    expect(page).to have_selector("h2", text: I18n.t('views.ctc.questions.confirm_mailing_address.mailing_address'))
    expect(page).to have_selector("div", text: "26 William Street")
    expect(page).to have_selector("div", text: "Apt 1234")
    expect(page).to have_selector("div", text: "Bel Air, CA 90001")
    click_on I18n.t('general.confirm')
  end

  def fill_in_ip_pins(dependent: true)
    # =========== IP PINs ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.ip_pin.title'))
    expect(page).not_to have_text "Sam NotQualified"
    check "Gary Mango III"
    check "Jessie M Pepper" if dependent
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.ip_pin_entry.title'))
    fill_in I18n.t('views.ctc.questions.ip_pin_entry.label', name: "Gary Mango III"), with: "123456"
    fill_in I18n.t('views.ctc.questions.ip_pin_entry.label', name: "Jessie M Pepper"), with: "123458" if dependent
    click_on I18n.t('general.continue')
  end

  def fill_in_review(filing_status: "married_filing_jointly", home_location: "fifty_states", dependent: true)
    married_filing_jointly = filing_status == "married_filing_jointly"
    # =========== REVIEW ===========
    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_information.title"))

    expect(page).to have_selector("h2", text: I18n.t("views.ctc.questions.confirm_information.your_information"))
    within ".primary-info" do
      expect(page).to have_selector("div", text: "Gary Mango III")
      expect(page).to have_selector("div", text: "#{I18n.t('hub.clients.show.date_of_birth')}: 8/24/1996")
      expect(page).to have_selector("div", text: "#{I18n.t('general.email')}: mango@example.com")
      expect(page).to have_selector("div", text: "#{I18n.t('general.phone')}: (831) 234-5678")
      expect(page).to have_selector("div", text: "#{I18n.t('general.ssn')}: XXX-XX-8888")
      click_on "edit"
    end

    fill_in "Legal first name", with: "Garold"
    click_on "Save"

    within ".primary-info" do
      expect(page).to have_selector("div", text: "Garold Mango III")
    end

    expect(page).to have_selector("h2", text: I18n.t("views.ctc.questions.confirm_mailing_address.mailing_address"))

    within ".address-info" do
      expect(page).to have_selector("div", text: "26 William Street")
      expect(page).to have_selector("div", text: "Apt 1234")
      expect(page).to have_selector("div", text: "Bel Air, CA 90001")
      click_on "edit"
    end

    fill_in "Street address", with: "28 William Street"
    click_on "Save"

    within ".address-info" do
      expect(page).to have_selector("div", text: "28 William Street")
    end

    if married_filing_jointly
      expect(page).to have_selector("h2", text: I18n.t("views.ctc.questions.spouse_review.your_spouse"))

      within ".spouse-info" do
        expect(page).to have_selector("div", text: "Peter P Pepper")
        expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 1/11/1995")
        expect(page).to have_selector("div", text: "#{I18n.t('general.ssn')}: XXX-XX-4444")
        click_on "edit"
      end

      fill_in "Spouse's legal first name", with: "Petra"
      click_on "Save"

      within ".spouse-info" do
        expect(page).to have_selector("div", text: "Petra P Pepper")
      end
    end

    # TODO: add tests for displaying dependent info after we allow the creation of qualifying dependents

    expect(page).to have_selector("h2", text: I18n.t("views.ctc.questions.confirm_bank_account.bank_information"))
    expect(page).to have_selector("li", text: "Bank of Two Melons")
    expect(page).to have_selector("li", text: "#{I18n.t('general.type')}: Checking")
    expect(page).to have_selector("li", text: "#{I18n.t('general.bank_account.routing_number')}: 019456124")
    expect(page).to have_selector("li", text: "#{I18n.t('general.bank_account.account_number')}: ●●●●●6789")

    fill_in I18n.t("views.ctc.questions.confirm_information.labels.signature_pin", name: "Garold Mango III"), with: "12345"
    if married_filing_jointly
      fill_in I18n.t("views.ctc.questions.confirm_information.labels.signature_pin", name: "Petra Pepper"), with: "54321"
    end
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_payment.title"))
    expect(page).to have_selector("p", text:  I18n.t("views.ctc.questions.confirm_payment.ctc_due"))
    expect(page).to have_selector("p", text:  "$2,600") if dependent

    if home_location == "puerto_rico"
      expect(page).not_to have_selector("p", text:  I18n.t("views.ctc.questions.confirm_payment.third_stimulus"))
    else
      expect(page).to have_selector("p", text:  I18n.t("views.ctc.questions.confirm_payment.third_stimulus"))
      expect(page).to have_selector("p", text:  married_filing_jointly ? "$2,400" : "$1,000")
    end

    click_on I18n.t('general.confirm')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.irs_language_preference.title"))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.drivers_license.title"))
    select "Ohio", from: I18n.t('views.ctc.questions.drivers_license.state')
    fill_in I18n.t("views.ctc.questions.drivers_license.license_number"), with: "OH123456"
    fill_in "ctc_drivers_license_form[issue_date_month]", with: "01"
    fill_in "ctc_drivers_license_form[issue_date_day]", with: "01"
    fill_in "ctc_drivers_license_form[issue_date_year]", with: "2020"
    fill_in "ctc_drivers_license_form[expiration_date_month]", with: "01"
    fill_in "ctc_drivers_license_form[expiration_date_day]", with: "01"
    fill_in "ctc_drivers_license_form[expiration_date_year]", with: "2024"
    click_on I18n.t('general.continue')

    if married_filing_jointly
      expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.spouse_drivers_license.title", spouse_first_name: "Petra"))
      click_on I18n.t('general.skip')
    end

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_legal.title"))
    check I18n.t("views.ctc.questions.confirm_legal.consent")
    click_on I18n.t("views.ctc.questions.confirm_legal.action")
  end

  def current_tax_year
    MultiTenantService.new(:ctc).current_tax_year
  end

  def prior_tax_year
    MultiTenantService.new(:ctc).prior_tax_year
  end
end
