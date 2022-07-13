require "rails_helper"

RSpec.feature "Web Intake Client matches with partner who is at capacity", :flow_explorer_screenshot do
  let(:intake) { create :intake }

  before do
    login_as(intake.client, scope: :client)
    routing_service_double = instance_double(PartnerRoutingService)

    allow(routing_service_double).to receive(:routing_method).and_return :at_capacity
    allow(routing_service_double).to receive(:determine_partner).and_return nil
    allow(PartnerRoutingService).to receive(:new).and_return routing_service_double
    allow_any_instance_of(ApplicationController).to receive(:current_intake).and_return(intake)
  end

  scenario "client decides cannot continue to diy" do
    # at first, sees at capacity page when resuming.
    # After updating routing method, does not see at capacity page.
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
    click_on "Return to homepage"
    click_on "Sign in"
    expect(page).to have_text "Welcome back"
    click_on "Complete all tax questions"
    expect(page).to have_content "GetYourRefund's tax preparation partners are currently at capacity."

    Client.last.update(routing_method: "hub_assignment")
    visit current_path
    expect(page).not_to have_content "GetYourRefund's tax preparation partners are currently at capacity."
    expect(page).to have_content I18n.t("views.questions.optional_consent.title")
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

