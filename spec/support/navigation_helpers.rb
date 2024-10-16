module NavigationHelpers
  def authenticate_client(client)
    expect(page).to have_text I18n.t("portal.client_logins.new.title")
    fill_in "Email address", with: client.intake.email_address
    click_on "Send code"
    expect(page).to have_text "Let’s verify that code!"

    perform_enqueued_jobs

    mail = ActionMailer::Base.deliveries.last
    code = mail.html_part.body.to_s.match(%r{<strong> (\d{6})\.</strong>})[1]

    fill_in "Enter 6 digit code", with: code
    click_on "Verify"

    fill_in "Client ID or Last 4 of SSN/ITIN", with: client.id
    click_on "Continue"
  end

  def go_back
    page.evaluate_script('window.history.back()')
  end

  def fill_out_personal_information(name: "Betty Banana", zip_code:, birth_date: Date.parse("1983-10-12"), phone_number: "415-888-0088")
    expect(page).to have_text I18n.t('views.questions.personal_info.title')
    fill_in I18n.t('views.questions.personal_info.preferred_name'), with: name
    select birth_date.strftime("%B"), from: "personal_info_form[birth_date_month]"
    select birth_date.day, from: "personal_info_form[birth_date_day]"
    select birth_date.year, from: "personal_info_form[birth_date_year]"
    fill_in I18n.t('views.questions.personal_info.zip_code'), with: zip_code
    fill_in I18n.t('views.questions.personal_info.phone_number'), with: phone_number
    fill_in I18n.t('views.questions.personal_info.phone_number_confirmation'), with: phone_number
    click_on I18n.t('general.continue')
  end

  def complete_intake_through_code_verification(
    primary_first_name: "Gary",
    primary_middle_initial: "H",
    primary_last_name: "Mango",
    primary_birth_date: Date.parse('1996-08-24'),
    primary_email: "mango@example.com",
    primary_ssn: "111-22-8888",
    sms_phone_number: "831-234-5678",
    claim_eitc: false
  )
    visit "/en/questions/overview"
    expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.main_home.title', current_tax_year: MultiTenantService.new(:ctc).current_tax_year))
    choose I18n.t('views.ctc.questions.main_home.options.fifty_states')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filing_status.title', current_tax_year: MultiTenantService.new(:ctc).current_tax_year))
    click_on I18n.t('general.negative')

    expect(page).to have_selector(".toolbar", text: "GetCTC")
    expect(page).to have_text(I18n.t("views.ctc.questions.income_qualifier.subtitle"))
    click_on I18n.t('general.affirmative')
    click_on I18n.t('general.continue')
    click_on I18n.t("views.ctc.questions.file_full_return.simplified_btn")
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.claim_eitc.title'))
    click_on claim_eitc ? I18n.t('views.ctc.questions.claim_eitc.buttons.claim') : I18n.t('views.ctc.questions.claim_eitc.buttons.dont_claim')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.restrictions.title'))
    click_on I18n.t('general.continue')

    # =========== ELIGIBILITY ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.already_filed.title', current_tax_year: MultiTenantService.new(:ctc).current_tax_year))
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.life_situations.title', current_tax_year: MultiTenantService.new(:ctc).current_tax_year))
    click_on I18n.t('general.negative')

    # =========== BASIC INFO ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.legal_consent.title'))
    fill_in I18n.t('views.ctc.questions.legal_consent.first_name'), with: primary_first_name
    fill_in I18n.t('views.ctc.questions.legal_consent.middle_initial'), with: primary_middle_initial
    fill_in I18n.t('views.ctc.questions.legal_consent.last_name'), with: primary_last_name
    fill_in "ctc_legal_consent_form_primary_birth_date_month", with: primary_birth_date.month
    fill_in "ctc_legal_consent_form_primary_birth_date_day", with: primary_birth_date.day
    fill_in "ctc_legal_consent_form_primary_birth_date_year", with: primary_birth_date.year
    fill_in I18n.t('views.ctc.questions.legal_consent.ssn'), with: primary_ssn
    fill_in I18n.t('views.ctc.questions.legal_consent.ssn_confirmation'), with: primary_ssn
    fill_in I18n.t('views.ctc.questions.legal_consent.sms_phone_number'), with: sms_phone_number
    check "agree_to_privacy_policy"
    click_on I18n.t('general.continue')

    prior_tax_year = MultiTenantService.new(:ctc).prior_tax_year
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filed_prior_tax_year.title', prior_tax_year: prior_tax_year))
    choose I18n.t('views.ctc.questions.filed_prior_tax_year.did_not_file', prior_tax_year: prior_tax_year)
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.contact_preference.title'))
    click_on I18n.t('views.ctc.questions.contact_preference.email')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.email_address.title'))
    fill_in I18n.t('views.questions.email_address.email_address'), with: primary_email
    fill_in I18n.t('views.questions.email_address.email_address_confirmation'), with: primary_email
    click_on I18n.t('general.continue')

    expect(page).to have_selector("p", text: I18n.t('views.ctc.questions.verification.body').strip)

    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]

    fill_in I18n.t('views.ctc.questions.verification.verification_code_label'), with: "000001"
    click_on I18n.t("views.ctc.questions.verification.verify")
    expect(page).to have_content(I18n.t('views.ctc.questions.verification.error_message'))

    fill_in I18n.t('views.ctc.questions.verification.verification_code_label'), with: code
    click_on I18n.t("views.ctc.questions.verification.verify")
  end
end
