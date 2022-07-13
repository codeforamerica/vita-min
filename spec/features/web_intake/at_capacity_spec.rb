require "rails_helper"

RSpec.feature "Web Intake Client matches with partner who is at capacity", :flow_explorer_screenshot do
  let(:intake) { create :intake }

  before do
    login_as(intake.client, scope: :client)
    fake_routing_service = instance_double(PartnerRoutingService)
    allow(fake_routing_service).to receive(:routing_method).and_return(:at_capacity)
    allow(fake_routing_service).to receive(:determine_partner).and_return(nil)
    allow(PartnerRoutingService).to receive(:new).and_return(instance_double(PartnerRoutingService))
  end

  scenario "client decides cannot continue to diy" do
    # do intake, get auto logged out on the at capacity page
    # use either the hub or some code directly to mutate the routing method for the client & vita partner for the client
    # log in & don't see at_capacity page but instead the next one in intake
    visit overview_questions_path
    expect(page).to have_selector("h1", text: "Just a few simple steps to file!")
    click_on "Continue"

    select "Social Security Number (SSN)", from: "Identification Type"
    fill_in I18n.t("attributes.primary_ssn"), with: "123-45-6789"
    fill_in I18n.t("attributes.confirm_primary_ssn"), with: "123-45-6789"
    click_on "Continue"

    expect(page).to have_selector("h1", text: I18n.t("views.questions.backtaxes.title"))
    check "#{TaxReturn.current_tax_year}"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Let's get started")
    click_on "Continue"

    expect(page).to have_select("What is your preferred language for the review?", selected: "English")
    click_on "Continue"

    expect(page).to have_text(I18n.t("views.questions.notification_preference.title"))
    check "Email Me"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Please share your email address.")
    fill_in "Email address", with: "gary.gardengnome@example.green"
    fill_in "Confirm email address", with: "gary.gardengnome@example.green"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Let's verify that contact info with a code!")
    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]
    fill_in "Enter 6 digit code", with: code
    click_on "Verify"

    expect(page).to have_selector("h1", text: I18n.t('views.questions.consent.title'))
    fill_in I18n.t("views.questions.consent.primary_first_name"), with: "Gary"
    fill_in I18n.t("views.questions.consent.primary_last_name"), with: "Gnome"
    select I18n.t("date.month_names")[3], from: "consent_form_birth_date_month"
    select "5", from: "consent_form_birth_date_day"
    select "1971", from: "consent_form_birth_date_year"
    click_on I18n.t("views.questions.consent.cta")

    expect(page).to have_selector("h1", text: I18n.t("views.questions.at_capacity.title"))
    next




    fill_in I18n.t('views.questions.personal_info.preferred_name'), with: "Gary"
    fill_in I18n.t('views.questions.personal_info.phone_number'), with: "Gary"

    fill_in I18n.t('views.ctc.questions.legal_consent.ssn'), with: "111-22-8888"
    fill_in I18n.t('views.ctc.questions.legal_consent.ssn_confirmation'), with: "111-22-8888"
    fill_in I18n.t('views.ctc.questions.legal_consent.sms_phone_number'), with: "831-234-5678"
    check I18n.t('views.ctc.questions.legal_consent.primary_active_armed_forces', current_tax_year: current_tax_year)
    check "agree_to_privacy_policy"
    visit at_capacity_questions_path

    expect(page).to have_selector("h1", text: I18n.t("views.questions.at_capacity.title"))
    click_on I18n.t("views.questions.at_capacity.return_to_homepage")
    expect(page).to have_selector("h1", text:  I18n.t("views.public_pages.home.header"))
  end

  scenario "client chooses the DIY option" do
    visit at_capacity_questions_path

    expect(page).to have_text I18n.t("views.questions.at_capacity.body_html")[1]
    expect(page).to have_selector("h1", text: I18n.t("views.questions.at_capacity.title"))
    click_on I18n.t("views.questions.at_capacity.continue_to_diy")

    expect(page).to have_selector("h1", text: "To access this site, please provide your e-mail address.")
    expect(intake.viewed_at_capacity).to be_truthy
    expect(intake.continued_at_capacity).to be_falsey
  end
end
