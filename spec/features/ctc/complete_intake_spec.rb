require "rails_helper"

RSpec.feature "CTC Intake", :flow_explorer_screenshot_i18n_friendly, active_job: true do
  def strip_inner_newlines(text)
    text.gsub(/\n/, '')
  end

  def strip_html_tags(text)
    ActionController::Base.helpers.strip_tags(text)
  end

  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  scenario "new client entering ctc intake flow" do
    # =========== BASIC INFO ===========
    visit "/en/questions/overview"
    expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector(".toolbar", text: "GetCTC")
    within "h1" do
      expect(page.source).to include(I18n.t('views.ctc.questions.income.title', tax_year: 2020))
    end
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.file_full_return.title"))
    click_on I18n.t("views.ctc.questions.file_full_return.full_btn")

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.legal_consent.title'))
    fill_in I18n.t('views.ctc.questions.legal_consent.first_name'), with: "Gary"
    fill_in I18n.t('views.ctc.questions.legal_consent.middle_initial'), with: "H"
    fill_in I18n.t('views.ctc.questions.legal_consent.last_name'), with: "Mango"
    fill_in "ctc_consent_form_primary_birth_date_month", with: "08"
    fill_in "ctc_consent_form_primary_birth_date_day", with: "24"
    fill_in "ctc_consent_form_primary_birth_date_year", with: "1996"
    fill_in I18n.t('views.ctc.questions.legal_consent.ssn'), with: "111-22-8888"
    fill_in I18n.t('views.ctc.questions.legal_consent.ssn_confirmation'), with: "111-22-8888"
    fill_in I18n.t('views.ctc.questions.legal_consent.sms_phone_number'), with: "831-234-5678"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.contact_preference.title'))
    click_on I18n.t('views.ctc.questions.contact_preference.text')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.cell_phone_number.title'))
    fill_in I18n.t('views.ctc.questions.cell_phone_number.label'), with: "8324658840"
    fill_in I18n.t('views.ctc.questions.cell_phone_number.confirm_label'), with: "8324658840"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.cell_phone_number.title'))
    within ".text--error" do
      expect(strip_inner_newlines(page.text)).to eq(strip_inner_newlines(strip_html_tags(I18n.t('views.ctc.questions.cell_phone_number.must_receive_texts_html'))))
    end

    click_on Nokogiri::HTML(I18n.t('views.ctc.questions.cell_phone_number.must_receive_texts_html')).css('a').text

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.email_address.title'))
    fill_in I18n.t('views.questions.email_address.email_address'), with: "mango@example.com"
    fill_in I18n.t('views.questions.email_address.email_address_confirmation'), with: "mango@example.com"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("p", text: I18n.t('views.ctc.questions.verification.body').strip)

    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]

    fill_in I18n.t('views.ctc.questions.verification.verification_code_label'), with: "000001"
    click_on I18n.t('general.continue')
    expect(page).to have_content(I18n.t('views.ctc.questions.verification.error_message'))

    fill_in I18n.t('views.ctc.questions.verification.verification_code_label'), with: code
    click_on I18n.t('general.continue')

    # =========== LIFE SITUATIONS ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filed_2020.title'))
    click_on I18n.t('general.negative')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filed_2019.title'))
    click_on I18n.t('general.affirmative')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.life_situations_2019.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.home.title'))
    check I18n.t('views.ctc.questions.home.options.fifty_states')
    check I18n.t('views.ctc.questions.home.options.foreign_address')
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text:  I18n.t('views.ctc.questions.use_gyr.title'))
    click_on I18n.t('general.back')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.home.title'))
    check I18n.t('views.ctc.questions.home.options.fifty_states')
    check I18n.t('views.ctc.questions.home.options.military_facility')
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.life_situations_2020.title'))
    check I18n.t('views.ctc.questions.life_situations_2020.cannot_claim_me_as_a_dependent')
    click_on I18n.t('general.continue')

    # =========== FILING STATUS ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filing_status.title'))
    choose I18n.t('general.filing_status.married_filing_jointly')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.spouse_info.title'))
    fill_in I18n.t('views.ctc.questions.spouse_info.spouse_first_name'), with: "Peter"
    fill_in I18n.t('views.ctc.questions.spouse_info.spouse_middle_initial'), with: "P"
    fill_in I18n.t('views.ctc.questions.spouse_info.spouse_last_name'), with: "Pepper"
    fill_in "ctc_spouse_info_form[spouse_birth_date_month]", with: "01"
    fill_in "ctc_spouse_info_form[spouse_birth_date_day]", with: "11"
    fill_in "ctc_spouse_info_form[spouse_birth_date_year]", with: "1995"
    select I18n.t('general.tin.ssn')
    fill_in I18n.t('views.ctc.questions.spouse_info.spouse_ssn_itin'), with: "222-33-4444"
    fill_in I18n.t('views.ctc.questions.spouse_info.spouse_ssn_itin_confirmation'), with: "222-33-4444"
    click_on I18n.t('views.ctc.questions.spouse_info.save_button')
    expect(page).not_to have_text(I18n.t('views.ctc.questions.spouse_info.remove_button'))

    expect(page).to have_text(I18n.t('views.ctc.questions.spouse_review.title'))
    expect(page).to have_text("Peter Pepper")
    expect(page).to have_text(I18n.t('views.ctc.questions.spouse_review.spouse_birthday', dob: "1/11/1995"))
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

    # =========== DEPENDENTS ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.had_dependents.title'))
    if Capybara.current_driver == Capybara.javascript_driver
      page.execute_script("document.querySelector('.reveal').remove()")
    end
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.no_dependents.title'))
    click_on I18n.t('general.back')
    if Capybara.current_driver == Capybara.javascript_driver
      page.execute_script("document.querySelector('.reveal').remove()")
    end
    click_on I18n.t('general.affirmative')

    dependent_birth_year = 22.years.ago.year

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.info.title'))
    fill_in I18n.t('views.ctc.questions.dependents.info.first_name'), with: "Jessie"
    fill_in I18n.t('views.ctc.questions.dependents.info.middle_initial'), with: "M"
    fill_in I18n.t('views.ctc.questions.dependents.info.last_name'), with: "Pepper"
    fill_in "ctc_dependents_info_form[birth_date_month]", with: "01"
    fill_in "ctc_dependents_info_form[birth_date_day]", with: "11"
    fill_in "ctc_dependents_info_form[birth_date_year]", with: dependent_birth_year
    select I18n.t('general.dependent_relationships.00_daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
    check I18n.t('views.ctc.questions.dependents.info.full_time_student')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_disqualifiers.title', name: 'Jessie'))
    check I18n.t('general.none')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_lived_with_you.title', name: 'Jessie', tax_year: '2020'))
    click_on I18n.t('general.affirmative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_can_be_claimed_by_other.title', name: 'Jessie'))
    click_on I18n.t('general.affirmative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.tin.title', name: 'Jessie'))
    select "Social Security Number (SSN)"
    fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin', name: "Jessie"), with: "222-33-4445"
    fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin_confirmation', name: "Jessie"), with: "222-33-4445"
    click_on I18n.t('views.ctc.questions.dependents.tin.remove_person')

    within "h1" do
      expect(strip_inner_newlines(page.text)).to eq(strip_inner_newlines(strip_html_tags(I18n.t("views.ctc.questions.dependents.remove_dependent.title_html", dependent_name: "Jessie"))))
    end
    click_on I18n.t('views.ctc.questions.dependents.remove_dependent.nevermind_button')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.tin.title', name: 'Jessie'))
    select "Social Security Number (SSN)"
    fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin', name: "Jessie"), with: "222-33-4445"
    fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin_confirmation', name: "Jessie"), with: "222-33-4445"
    click_on I18n.t('views.ctc.questions.dependents.tin.save_person')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.confirm_dependents.title'))
    expect(page).to have_content("Jessie Pepper")
    expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 1/11/#{dependent_birth_year}")

    # Back up to prove that the 'go back' button brings us back to the dependent we were editing
    click_on I18n.t('general.back')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.tin.title', name: 'Jessie'))
    click_on I18n.t('views.ctc.questions.dependents.tin.save_person')
    click_on I18n.t('views.ctc.questions.dependents.confirm_dependents.done_adding')

    # =========== RECOVERY REBATE CREDIT ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_payments.title'))
    expect(page).to have_selector(".first-stimulus", text: "$2,400")
    expect(page).to have_selector(".second-stimulus", text: "$1,200")

    click_on I18n.t('views.ctc.questions.stimulus_payments.no_did_not_receive')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_one.title'))
    click_on I18n.t('general.affirmative')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_one_received.title'))
    fill_in I18n.t('views.ctc.questions.stimulus_one_received.eip1_amount_received_label'), with: "2400"
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_two.title'))
    click_on I18n.t('general.affirmative')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_two_received.title'))
    fill_in I18n.t('views.ctc.questions.stimulus_two_received.eip2_amount_received_label'), with: "1200"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_received.title'))
    expect(page).to have_text("#{I18n.t('views.ctc.questions.stimulus_received.eip_one')}: $2,400")
    expect(page).to have_text("#{I18n.t('views.ctc.questions.stimulus_received.eip_two')}: $1,200")
    click_on I18n.t('general.continue')

    # =========== BANK AND MAILING INFO ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.refund_payment.title'))
    choose I18n.t('views.questions.refund_payment.direct_deposit')
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.questions.bank_details.title'))
    fill_in I18n.t('views.questions.bank_details.bank_name'), with: "Bank of Two Melons"
    choose I18n.t('views.questions.bank_details.account_type.checking')
    check I18n.t('views.ctc.questions.direct_deposit.my_bank_account.label')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.routing_number.title'))
    fill_in I18n.t('views.ctc.questions.routing_number.routing_number'), with: "12345678"
    fill_in I18n.t('views.ctc.questions.routing_number.routing_number_confirmation'), with: "12345678"
    click_on I18n.t('general.continue')
    expect(page).to have_selector(".text--error", text: I18n.t('errors.messages.wrong_length', count: 9))
    fill_in I18n.t('views.ctc.questions.routing_number.routing_number'), with: "123456789"
    fill_in I18n.t('views.ctc.questions.routing_number.routing_number_confirmation'), with: "123456789"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.account_number.title'))
    fill_in I18n.t('views.ctc.questions.account_number.account_number'), with: "123456789"
    fill_in I18n.t('views.ctc.questions.account_number.account_number_confirmation'), with: "123456789"
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_bank_account.title'))
    expect(page).to have_selector("h2", text: I18n.t('views.ctc.questions.confirm_bank_account.bank_information'))
    expect(page).to have_selector("li", text: "Bank of Two Melons")
    expect(page).to have_selector("li", text: "#{I18n.t('general.type')}: Checking")
    expect(page).to have_selector("li", text: "#{I18n.t('general.bank_account.routing_number')}: 123456789")
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
    click_on I18n.t('general.continue')

    # =========== IP PINs ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.ip_pin.title'))
    check "Gary Mango"
    check "Jessie Pepper"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.ip_pin_entry.title'))
    fill_in I18n.t('views.ctc.questions.ip_pin_entry.label', name: "Gary Mango"), with: "123456"
    fill_in I18n.t('views.ctc.questions.ip_pin_entry.label', name: "Jessie Pepper"), with: "123458"
    click_on I18n.t('general.continue')

    # =========== REVIEW ===========
    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_information.title"))

    expect(page).to have_selector("h2", text: I18n.t("views.ctc.questions.confirm_information.your_information"))
    expect(page).to have_selector("div", text: "Gary Mango")
    expect(page).to have_selector("div", text: "#{I18n.t('hub.clients.show.date_of_birth')}: 8/24/1996")
    expect(page).to have_selector("div", text: "#{I18n.t('general.email')}: mango@example.com")
    expect(page).to have_selector("div", text: "#{I18n.t('general.phone')}: (831) 234-5678")
    expect(page).to have_selector("div", text: "#{I18n.t('general.ssn')}: XXX-XX-8888")

    expect(page).to have_selector("h2", text: I18n.t("views.ctc.questions.confirm_mailing_address.mailing_address"))
    expect(page).to have_selector("div", text: "26 William Street")
    expect(page).to have_selector("div", text: "Apt 1234")
    expect(page).to have_selector("div", text: "Bel Air, CA 90001")

    expect(page).to have_selector("h2", text: I18n.t("views.ctc.questions.spouse_review.your_spouse"))
    expect(page).to have_selector("div", text: "Peter Pepper")
    expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 1/11/1995")
    expect(page).to have_selector("div", text: "#{I18n.t('general.ssn')}: XXX-XX-4444")

    # TODO: add tests for displaying dependent info after we allow the creation of qualifying dependents

    expect(page).to have_selector("h2", text: I18n.t("views.ctc.questions.confirm_bank_account.bank_information"))
    expect(page).to have_selector("li", text: "Bank of Two Melons")
    expect(page).to have_selector("li", text: "#{I18n.t('general.type')}: Checking")
    expect(page).to have_selector("li", text: "#{I18n.t('general.bank_account.routing_number')}: 123456789")
    expect(page).to have_selector("li", text: "#{I18n.t('general.bank_account.account_number')}: ●●●●●6789")

    fill_in I18n.t("views.ctc.questions.confirm_information.labels.signature_pin", name: "Gary Mango"), with: "12345"
    fill_in I18n.t("views.ctc.questions.confirm_information.labels.signature_pin", name: "Peter Pepper"), with: "54321"
    click_on I18n.t('views.ctc.questions.confirm_information.ready_to_file')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_legal.title"))
    check I18n.t("views.ctc.questions.confirm_legal.consent")
    click_on I18n.t("views.ctc.questions.confirm_legal.action")

    # =========== PORTAL ===========
    expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
    expect(page).to have_text(I18n.t("views.ctc.portal.home.status.preparing.label"))
  end
end
