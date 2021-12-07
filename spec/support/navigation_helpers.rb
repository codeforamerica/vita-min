module NavigationHelpers
  def go_back
    page.evaluate_script('window.history.back()')
  end

  def complete_intake_through_code_verification(
    primary_first_name: "Gary",
    primary_middle_initial: "H",
    primary_last_name: "Mango",
    primary_birth_date: Date.parse('1996-08-24'),
    primary_email: "mango@example.com",
    primary_ssn: "111-22-8888",
    sms_phone_number: "831-234-5678"
  )
    visit "/en/questions/overview"
    expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector(".toolbar", text: "GetCTC")
    click_on I18n.t('general.negative')
    click_on I18n.t("views.ctc.questions.file_full_return.simplified_btn")

    # =========== ELIGIBILITY ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.already_filed.title'))
    click_on I18n.t('general.negative')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filed_prior_tax_year.title', prior_tax_year: prior_tax_year))
    choose I18n.t('views.ctc.questions.filed_prior_tax_year.did_not_file', prior_tax_year: prior_tax_year)
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.home.title'))
    check I18n.t('views.ctc.questions.home.options.fifty_states')
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.life_situations.title', current_tax_year: current_tax_year))
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
