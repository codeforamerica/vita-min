require "rails_helper"

RSpec.feature "CTC Intake", :flow_explorer_screenshot_i18n_friendly, active_job: true, requires_default_vita_partners: true do
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
    allow_any_instance_of(FraudIndicatorService).to receive(:hold_indicators).and_return([])
  end

  scenario "new client entering ctc intake flow" do
    # =========== BASIC INFO ===========
    visit "/en/questions/overview"
    expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector(".toolbar", text: "GetCTC")
    within "h1" do
      expect(page.source).to include(I18n.t('views.ctc.questions.income.title', current_tax_year: current_tax_year))
    end
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.file_full_return.title"))
    click_on I18n.t("views.ctc.questions.file_full_return.simplified_btn")

    # =========== ELIGIBILITY ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.already_filed.title', current_tax_year: current_tax_year))
    click_on I18n.t('general.negative')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filed_prior_tax_year.title', prior_tax_year: prior_tax_year))
    choose I18n.t('views.ctc.questions.filed_prior_tax_year.did_not_file', prior_tax_year: prior_tax_year)
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.home.title', current_tax_year: current_tax_year))
    check I18n.t('views.ctc.questions.home.options.fifty_states')
    check I18n.t('views.ctc.questions.home.options.foreign_address')
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.use_gyr.title'))
    click_on I18n.t('general.back')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.home.title', current_tax_year: current_tax_year))
    check I18n.t('views.ctc.questions.home.options.fifty_states')
    check I18n.t('views.ctc.questions.home.options.military_facility')
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.life_situations.title', current_tax_year: current_tax_year))
    click_on I18n.t('general.negative')

    # =========== BASIC INFO ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.legal_consent.title'))
    fill_in I18n.t('views.ctc.questions.legal_consent.first_name'), with: "Gary"
    fill_in I18n.t('views.ctc.questions.legal_consent.middle_initial'), with: "H"
    fill_in I18n.t('views.ctc.questions.legal_consent.last_name'), with: "Mango"
    select "III", from: I18n.t('views.ctc.questions.legal_consent.suffix')
    fill_in "ctc_legal_consent_form_primary_birth_date_month", with: "08"
    fill_in "ctc_legal_consent_form_primary_birth_date_day", with: "24"
    fill_in "ctc_legal_consent_form_primary_birth_date_year", with: "1996"
    fill_in I18n.t('views.ctc.questions.legal_consent.ssn'), with: "111-22-8888"
    fill_in I18n.t('views.ctc.questions.legal_consent.ssn_confirmation'), with: "111-22-8888"
    fill_in I18n.t('views.ctc.questions.legal_consent.sms_phone_number'), with: "831-234-5678"
    check I18n.t('views.ctc.questions.legal_consent.primary_active_armed_forces.title', current_tax_year: current_tax_year)
    click_on I18n.t('views.ctc.questions.legal_consent.agree')


    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.contact_preference.title'))
    click_on I18n.t('views.ctc.questions.contact_preference.email')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.email_address.title'))
    fill_in I18n.t('views.questions.email_address.email_address'), with: "mango@example.com"
    fill_in I18n.t('views.questions.email_address.email_address_confirmation'), with: "mango@example.com"
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

    # =========== FILING STATUS ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filing_status.title'))
    choose I18n.t('views.ctc.questions.filing_status.married_filing_jointly')
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

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.spouse_filed_prior_tax_year.title', prior_tax_year: prior_tax_year))
    choose I18n.t('views.ctc.questions.spouse_filed_prior_tax_year.did_not_file', prior_tax_year: prior_tax_year)
    click_on I18n.t('general.continue')

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
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.had_dependents.title', current_tax_year: current_tax_year))
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_payments.title'))
    click_on I18n.t('general.back')
    click_on I18n.t('general.affirmative')

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

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_expenses.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_residence.title', name: 'Jessie', current_tax_year: current_tax_year))
    click_on I18n.t('general.affirmative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_can_be_claimed_by_other.title', name: 'Jessie'))
    click_on I18n.t('general.affirmative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title'))
    expect(page).to have_content("Jessie M Pepper")
    expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 1/11/#{dependent_birth_year}")

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

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_expenses.title', name: 'Red', current_tax_year: TaxReturn.current_tax_year))
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_residence.title', name: 'Red', current_tax_year: current_tax_year))
    click_on I18n.t('general.affirmative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_can_be_claimed_by_other.title', name: 'Red'))
    click_on I18n.t('general.affirmative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title'))
    expect(page).to have_content("Red Hot Pepper")
    expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 1/11/#{dependent_birth_year}")

    within "#dependent_#{Dependent.last.id}" do
      click_on "edit"
    end

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.dependent_info.title", name: "Red"))
    click_on I18n.t("views.ctc.questions.dependents.tin.remove_person")
    expect(page).to have_text I18n.t("views.ctc.questions.dependents.remove_dependent.title", dependent_name: "Red")
    click_on I18n.t("views.ctc.questions.dependents.remove_dependent.remove_button")

    expect(page).to have_selector("h1", text: "Let’s confirm!")
    expect(page).not_to have_text "Red Hot Pepper"
    click_on I18n.t('views.ctc.questions.confirm_dependents.done_adding')


    # =========== RECOVERY REBATE CREDIT ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_payments.title'))
    expect(page).to have_selector(".first-stimulus", text: "$2,900")
    expect(page).to have_selector(".second-stimulus", text: "$1,800")

    click_on I18n.t('views.ctc.questions.stimulus_payments.no_did_not_receive')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_one.title'))
    click_on I18n.t('general.affirmative')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_one_received.title'))
    fill_in I18n.t('views.ctc.questions.stimulus_one_received.eip1_amount_received_label'), with: "2900"
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_two.title'))
    click_on I18n.t('general.affirmative')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_two_received.title'))
    fill_in I18n.t('views.ctc.questions.stimulus_two_received.eip2_amount_received_label'), with: "1800"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_received.title'))
    expect(page).to have_text("#{I18n.t('views.ctc.questions.stimulus_received.eip_one')}: $2,900")
    expect(page).to have_text("#{I18n.t('views.ctc.questions.stimulus_received.eip_two')}: $1,800")
    click_on I18n.t('general.continue')

    # =========== BANK AND MAILING INFO ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.refund_payment.title'))
    choose I18n.t('views.questions.refund_payment.direct_deposit')
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.portal.bank_account.title'))
    fill_in I18n.t('views.questions.bank_details.bank_name'), with: "Bank of Two Melons"
    choose I18n.t('views.questions.bank_details.account_type.checking')
    check I18n.t('views.ctc.questions.direct_deposit.my_bank_account.label')
    fill_in I18n.t('views.ctc.questions.routing_number.routing_number'), with: "123456789"
    fill_in I18n.t('views.ctc.questions.routing_number.routing_number_confirmation'), with: "123456789"
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
    check "Gary Mango III"
    check "Jessie M Pepper"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.ip_pin_entry.title'))
    fill_in I18n.t('views.ctc.questions.ip_pin_entry.label', name: "Gary Mango III"), with: "123456"
    fill_in I18n.t('views.ctc.questions.ip_pin_entry.label', name: "Jessie M Pepper"), with: "123458"
    click_on I18n.t('general.continue')

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

    expect(page).to have_selector("h2", text: I18n.t("views.ctc.questions.spouse_review.your_spouse"))

    within ".spouse-info" do
      expect(page).to have_selector("div", text: "Peter Pepper")
      expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 1/11/1995")
      expect(page).to have_selector("div", text: "#{I18n.t('general.ssn')}: XXX-XX-4444")
      click_on "edit"
    end

    fill_in "Spouse's legal first name", with: "Petra"
    click_on "Save"

    within ".spouse-info" do
      expect(page).to have_selector("div", text: "Petra Pepper")
    end

    # TODO: add tests for displaying dependent info after we allow the creation of qualifying dependents

    expect(page).to have_selector("h2", text: I18n.t("views.ctc.questions.confirm_bank_account.bank_information"))
    expect(page).to have_selector("li", text: "Bank of Two Melons")
    expect(page).to have_selector("li", text: "#{I18n.t('general.type')}: Checking")
    expect(page).to have_selector("li", text: "#{I18n.t('general.bank_account.routing_number')}: 123456789")
    expect(page).to have_selector("li", text: "#{I18n.t('general.bank_account.account_number')}: ●●●●●6789")

    fill_in I18n.t("views.ctc.questions.confirm_information.labels.signature_pin", name: "Garold Mango III"), with: "12345"
    fill_in I18n.t("views.ctc.questions.confirm_information.labels.signature_pin", name: "Petra Pepper"), with: "54321"
    click_on I18n.t('views.ctc.questions.confirm_information.ready_to_file')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_payment.title"))
    expect(page).to have_selector("p", text:  I18n.t("views.ctc.questions.confirm_payment.ctc_due"))
    expect(page).to have_selector("p", text:  "$1,800")
    expect(page).to have_selector("p", text:  I18n.t("views.ctc.questions.confirm_payment.rrc"))
    expect(page).to have_selector("p", text:  "$0")
    expect(page).to have_selector("p", text:  I18n.t("views.ctc.questions.confirm_payment.third_stimulus"))
    expect(page).to have_selector("p", text:  "$4,200")
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_legal.title"))
    check I18n.t("views.ctc.questions.confirm_legal.consent")
    click_on I18n.t("views.ctc.questions.confirm_legal.action")

    # =========== PORTAL ===========
    expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
    expect(page).to have_text(I18n.t("views.ctc.portal.home.status.preparing.label"))

    # ========= ADMIN HUB EDITING ======
    # Prove that making a simple edit in the hub to an intake that was
    # created in the normal flow only shows a minimal amount
    # of changes in the SystemNote
    Capybara.current_session.reset!

    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(false)
    login_as create :admin_user

    visit hub_client_path(id: Client.last.id)
    within ".client-profile" do
      click_on "Edit"
    end

    within "#primary-info" do
      fill_in "Legal first name", with: "Garnet"
      fill_in "Preferred full name", with: "Garnet Mango"
    end

    click_on "Save"
    click_on "Notes"

    expect(changes_table_contents('.changes-table')).to match({
      "preferred_name" => ["nil", "Garnet Mango"],
      "primary_first_name" => ["Garold", "Garnet"],
    })
  end

  scenario "client who has filed in 2019" do
    # =========== BASIC INFO ===========
    visit "/en/questions/overview"
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
    click_on I18n.t('general.continue')

    within "h1" do
      expect(page.source).to include(I18n.t('views.ctc.questions.income.title', current_tax_year: current_tax_year))
    end
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.file_full_return.title"))
    click_on I18n.t("views.ctc.questions.file_full_return.simplified_btn")

    # =========== ELIGIBILITY ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.already_filed.title', current_tax_year: current_tax_year))
    click_on I18n.t('general.negative')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filed_prior_tax_year.title', prior_tax_year: prior_tax_year))
    choose I18n.t('views.ctc.questions.filed_prior_tax_year.filed_full', prior_tax_year: prior_tax_year)
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.prior_tax_year_life_situations.title', current_tax_year: current_tax_year))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.home.title', current_tax_year: current_tax_year))
    check I18n.t('views.ctc.questions.home.options.fifty_states')
    check I18n.t('views.ctc.questions.home.options.military_facility')
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.life_situations.title', current_tax_year: current_tax_year))
    click_on I18n.t('general.negative')

    # =========== BASIC INFO ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.legal_consent.title'))
    fill_in I18n.t('views.ctc.questions.legal_consent.first_name'), with: "Gary"
    fill_in I18n.t('views.ctc.questions.legal_consent.middle_initial'), with: "H"
    fill_in I18n.t('views.ctc.questions.legal_consent.last_name'), with: "Mango"
    select "III", from: I18n.t('views.ctc.questions.legal_consent.suffix')
    fill_in "ctc_legal_consent_form_primary_birth_date_month", with: "08"
    fill_in "ctc_legal_consent_form_primary_birth_date_day", with: "24"
    fill_in "ctc_legal_consent_form_primary_birth_date_year", with: "1996"
    fill_in I18n.t('views.ctc.questions.legal_consent.ssn'), with: "111-22-8888"
    fill_in I18n.t('views.ctc.questions.legal_consent.ssn_confirmation'), with: "111-22-8888"
    fill_in I18n.t('views.ctc.questions.legal_consent.sms_phone_number'), with: "831-234-5678"
    check I18n.t('views.ctc.questions.legal_consent.primary_active_armed_forces.title', current_tax_year: current_tax_year)
    click_on I18n.t('views.ctc.questions.legal_consent.agree')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.prior_tax_year_agi.title'))
    fill_in I18n.t('views.ctc.questions.prior_tax_year_agi.label'), with: '$12,340'
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
    code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]

    fill_in I18n.t('views.ctc.questions.verification.verification_code_label'), with: "000001"
    click_on I18n.t("views.ctc.questions.verification.verify")
    expect(page).to have_content(I18n.t('views.ctc.questions.verification.error_message'))

    fill_in I18n.t('views.ctc.questions.verification.verification_code_label'), with: code
    click_on I18n.t("views.ctc.questions.verification.verify")

    # =========== FILING STATUS ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filing_status.title'))
    choose I18n.t('views.ctc.questions.filing_status.married_filing_jointly')
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
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.spouse_filed_prior_tax_year.title', prior_tax_year: prior_tax_year))
    choose I18n.t('views.ctc.questions.spouse_filed_prior_tax_year.filed_full_separate')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.spouse_prior_tax_year_agi.title', prior_tax_year: prior_tax_year))
    fill_in I18n.t('views.ctc.questions.prior_tax_year_agi.label'), with: '4,567'
    click_on I18n.t('general.continue')

    intake = Intake.last
    expect(intake.primary_prior_year_agi_amount).to eq(12340)
    expect(intake.spouse_prior_year_agi_amount).to eq(4567)
  end

  it "allows the basic filer info to be edited after it was created" do
    complete_intake_through_code_verification
    expect(Intake.count).to eq(1)

    visit "/en/questions/legal-consent"

    new_birth_date = Date.parse('1967-06-09')
    fill_in "ctc_legal_consent_form_primary_birth_date_month", with: new_birth_date.month
    fill_in "ctc_legal_consent_form_primary_birth_date_day", with: new_birth_date.day
    fill_in "ctc_legal_consent_form_primary_birth_date_year", with: new_birth_date.year
    click_on I18n.t('views.ctc.questions.legal_consent.agree')

    expect(Intake.count).to eq(1)
    expect(Intake.last.primary_birth_date).to eq(new_birth_date)
  end
end
