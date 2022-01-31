require "rails_helper"

feature "Intake Routing Spec", :flow_explorer_screenshot_i18n_friendly, :active_job do
  include MockTwilio

  def fill_out_notification_preferences
    # Notification Preference
    check I18n.t('views.questions.notification_preference.options.email_notification_opt_in')
    check I18n.t('views.questions.notification_preference.options.sms_notification_opt_in')
    click_on I18n.t('general.continue')

    # Phone number can text
    expect(page).to have_text("(415) 888-0088")
    click_on I18n.t('general.negative')

    # Phone number
    expect(page).to have_selector("h1", text: I18n.t("views.questions.phone_number.title"))
    fill_in I18n.t("views.questions.phone_number.phone_number"), with: "(415) 553-7865"
    fill_in I18n.t("views.questions.phone_number.phone_number_confirmation"), with: "+1415553-7865"
    click_on I18n.t('general.continue')

    # Verify cell phone contact
    perform_enqueued_jobs
    sms = FakeTwilioClient.messages.last
    code = sms.body.to_s.match(/\s(\d{6})[.]/)[1]
    fill_in I18n.t("views.questions.verification.verification_code_label"), with: code
    click_on I18n.t("views.questions.verification.verify")

    # Email
    fill_in I18n.t("views.questions.email_address.email_address"), with: "gary.gardengnome@example.green"
    fill_in I18n.t("views.questions.email_address.email_address_confirmation"), with: "gary.gardengnome@example.green"
    click_on I18n.t('general.continue')

    # Verify email contact
    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]
    fill_in I18n.t("views.questions.verification.verification_code_label"), with: code
    click_on I18n.t("views.questions.verification.verify")

    # Consent form
    fill_in I18n.t("views.questions.consent.primary_first_name"), with: "Gary"
    fill_in I18n.t("views.questions.consent.primary_last_name"), with: "Gnome"
    fill_in I18n.t("attributes.primary_ssn"), with: "123-45-6789"
    fill_in I18n.t("attributes.confirm_primary_ssn"), with: "123-45-6789"
    select I18n.t("date.month_names")[3], from: "consent_form_birth_date_month"
    select "5", from: "consent_form_birth_date_day"
    select "1971", from: "consent_form_birth_date_year"
    click_on I18n.t("views.questions.consent.cta")

    # Optional consent form
    expect(page).to have_selector("h1", text: I18n.t('views.questions.optional_consent.title'))
    toggles = {
      strip_html_tags(I18n.t('views.questions.optional_consent.consent_to_use_html')).split(':').first => consent_to_use_path,
      strip_html_tags(I18n.t('views.questions.optional_consent.consent_to_disclose_html')).split(':').first => consent_to_disclose_path,
      strip_html_tags(I18n.t('views.questions.optional_consent.relational_efin_html')).split(':').first => relational_efin_path,
      strip_html_tags(I18n.t('views.questions.optional_consent.global_carryforward_html')).split(':').first => global_carryforward_path,
    }
    toggles.each do |toggle_text, link_path|
      expect(page).to have_checked_field(toggle_text)
      expect(page).to have_link(toggle_text, href: link_path)
    end
    uncheck toggles.keys.last
    click_on I18n.t('general.continue')
  end

  let!(:expected_source_param_vita_partner) { create :organization, name: "Cobra Academy" }
  let!(:expected_zip_code_vita_partner) { create :organization, name: "Diagon Alley" }
  let!(:expected_state_vita_partner) { create :organization, name: "Hogwarts", capacity_limit: 10, coalition: create(:coalition) }
  let!(:source_parameter) { create :source_parameter, code: "cobra", vita_partner: expected_source_param_vita_partner }
  let!(:zip_code) { "94606" }
  let!(:vita_partner_zip_code) { create :vita_partner_zip_code, zip_code: zip_code, vita_partner: expected_zip_code_vita_partner }
  let(:state_routing_target) { create(:state_routing_target, target: expected_state_vita_partner.coalition, state_abbreviation: "NC") }
  let!(:state_routing_fraction) { create(:state_routing_fraction, state_routing_target: state_routing_target, routing_fraction: 0.2, vita_partner: expected_state_vita_partner) }

  scenario "routing by source param" do
    visit "/cobra"
    # expect redirect to locale path
    # expect that this sets a cookie that routes to cobra.

    expect(page).to have_text I18n.t('views.public_pages.home.header')

    # clients with matching vita partner source param skip triage questions
    click_on I18n.t("general.get_started"), id: "firstCta"
    expect(page).to have_text I18n.t("views.questions.welcome.title")
    click_on I18n.t('general.continue')

    expect(page).to have_text I18n.t('views.questions.backtaxes.title')
    check "2020"
    click_on I18n.t('general.continue')

    expect(Intake.last.source).to eq "cobra"
    expect(page).to have_text I18n.t('views.questions.environment_warning.title')
    click_on I18n.t('general.continue_example')

    expect(page).to have_text I18n.t('views.questions.start_with_current_year.title')
    click_on I18n.t('general.continue')

    expect(page).to have_text I18n.t('views.questions.overview.title')
    click_on I18n.t('general.continue')

    expect(page).to have_text I18n.t('views.questions.personal_info.title')
    fill_in I18n.t('views.questions.personal_info.preferred_name'), with: "Betty Banana"
    fill_in I18n.t('views.questions.personal_info.zip_code'), with: zip_code
    fill_in I18n.t('views.questions.personal_info.phone_number'), with: "415-888-0088"
    fill_in I18n.t('views.questions.personal_info.phone_number_confirmation'), with: "415-888-0088"
    click_on I18n.t('general.continue')

    fill_in I18n.t('views.questions.interview_scheduling.title'), with: "During school hours"
    click_on I18n.t('general.continue')

    fill_out_notification_preferences

    expect(page.html).to have_text I18n.t("views.questions.chat_with_us.title", partner_name: "Cobra Academy")
  end

  scenario "routing by zip code" do
    visit "/questions/backtaxes"

    expect(page).to have_text I18n.t('views.questions.backtaxes.title')
    check "2020"
    click_on I18n.t('general.continue')

    expect(Intake.last.source).to eq nil
    expect(page).to have_text I18n.t('views.questions.environment_warning.title')
    click_on I18n.t('general.continue_example')

    expect(page).to have_text I18n.t('views.questions.start_with_current_year.title')
    click_on I18n.t('general.continue')

    expect(page).to have_text I18n.t('views.questions.overview.title')
    click_on I18n.t('general.continue')

    expect(page).to have_text I18n.t('views.questions.personal_info.title')
    fill_in I18n.t('views.questions.personal_info.preferred_name'), with: "Minerva Mcgonagall"
    fill_in I18n.t('views.questions.personal_info.zip_code'), with: zip_code
    fill_in I18n.t('views.questions.personal_info.phone_number'), with: "415-888-0088"
    fill_in I18n.t('views.questions.personal_info.phone_number_confirmation'), with: "415-888-0088"
    click_on I18n.t('general.continue')

    fill_in I18n.t('views.questions.interview_scheduling.title'), with: "During school hours"
    click_on I18n.t('general.continue')

    fill_out_notification_preferences

    expect(page.html).to have_text I18n.t("views.questions.chat_with_us.title", partner_name: "Diagon Alley")
  end

  scenario "routing by state" do
    visit "/questions/backtaxes"

    expect(page).to have_text I18n.t('views.questions.backtaxes.title')
    check "2020"
    click_on I18n.t('general.continue')

    expect(Intake.last.source).to eq nil
    expect(page).to have_text I18n.t('views.questions.environment_warning.title')
    click_on I18n.t('general.continue_example')

    expect(page).to have_text I18n.t('views.questions.start_with_current_year.title')
    click_on I18n.t('general.continue')

    expect(page).to have_text I18n.t('views.questions.overview.title')
    click_on I18n.t('general.continue')

    expect(page).to have_text I18n.t('views.questions.personal_info.title')
    fill_in I18n.t('views.questions.personal_info.preferred_name'), with: "Luna Lovegood"
    fill_in I18n.t('views.questions.personal_info.zip_code'), with: "28806"
    fill_in I18n.t('views.questions.personal_info.phone_number'), with: "415-888-0088"
    fill_in I18n.t('views.questions.personal_info.phone_number_confirmation'), with: "415-888-0088"
    click_on I18n.t('general.continue')

    fill_in I18n.t('views.questions.interview_scheduling.title'), with: "During school hours"
    click_on I18n.t('general.continue')

    fill_out_notification_preferences

    expect(page.html).to have_text I18n.t("views.questions.chat_with_us.title", partner_name: "Hogwarts")
  end

  context "at capacity but overflow site exists" do
    let!(:default_vita_partner) { create :organization, name: "Default Organization", national_overflow_location: true }

    before do
      expected_state_vita_partner.update(capacity_limit: 0)
    end

    scenario "routes to national partner" do
      visit "/questions/backtaxes"

      expect(page).to have_text I18n.t('views.questions.backtaxes.title')
      check "2020"
      click_on I18n.t('general.continue')

      expect(Intake.last.source).to eq nil
      expect(page).to have_text I18n.t('views.questions.environment_warning.title')
      click_on I18n.t('general.continue_example')

      expect(page).to have_text I18n.t('views.questions.start_with_current_year.title')
      click_on I18n.t('general.continue')

      expect(page).to have_text I18n.t('views.questions.overview.title')
      click_on I18n.t('general.continue')

      expect(page).to have_text I18n.t('views.questions.personal_info.title')
      fill_in I18n.t('views.questions.personal_info.preferred_name'), with: "Luna Lovegood"
      fill_in I18n.t('views.questions.personal_info.zip_code'), with: "28806"
      fill_in I18n.t('views.questions.personal_info.phone_number'), with: "415-888-0088"
      fill_in I18n.t('views.questions.personal_info.phone_number_confirmation'), with: "415-888-0088"
      click_on I18n.t('general.continue')

      fill_in I18n.t('views.questions.interview_scheduling.title'), with: "During school hours"
      click_on I18n.t('general.continue')

      fill_out_notification_preferences

      expect(page.html).to have_text "Default Organization is here to help"
    end
  end

  context "vita partner is at capacity" do
    let!(:default_vita_partner) { create :organization, name: "Default Organization", national_overflow_location: false }

    before do
      expected_state_vita_partner.update(capacity_limit: 0)
    end

    scenario "would have been routed by state, redirects to at capacity page" do
      visit "/questions/backtaxes"

      expect(page).to have_text I18n.t('views.questions.backtaxes.title')
      check "2020"
      click_on I18n.t('general.continue')

      expect(Intake.last.source).to eq nil
      expect(page).to have_text I18n.t('views.questions.environment_warning.title')
      click_on I18n.t('general.continue_example')

      expect(page).to have_text I18n.t('views.questions.start_with_current_year.title')
      click_on I18n.t('general.continue')

      expect(page).to have_text I18n.t('views.questions.overview.title')
      click_on I18n.t('general.continue')

      expect(page).to have_text I18n.t('views.questions.personal_info.title')
      fill_in I18n.t('views.questions.personal_info.preferred_name'), with: "Luna Lovegood"
      fill_in I18n.t('views.questions.personal_info.zip_code'), with: "28806"
      fill_in I18n.t('views.questions.personal_info.phone_number'), with: "415-888-0088"
      fill_in I18n.t('views.questions.personal_info.phone_number_confirmation'), with: "415-888-0088"
      click_on I18n.t('general.continue')

      fill_in I18n.t('views.questions.interview_scheduling.title'), with: "During school hours"
      click_on I18n.t('general.continue')

      fill_out_notification_preferences

      expect(page.html).to have_text I18n.t('views.questions.at_capacity.title')
    end
  end
end
