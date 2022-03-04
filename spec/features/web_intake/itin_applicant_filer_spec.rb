require "rails_helper"

RSpec.feature "A client who wants help getting an ITIN" do
  include MockTwilio

  context "when an itin applicant is unique" do
    scenario "the client does not get blocked by returning client page and is sent to optional consent" do
      answer_gyr_triage_questions({
                                      filing_status: "single",
                                      income_level: "1_to_12500",
                                      id_type: "need_itin_help",
                                      doc_type: "need_help",
                                      filed_past_years: [],
                                      income_type_options: ['none_of_the_above']
                                  })

      expect(page).to have_selector("h1", text: I18n.t('questions.triage_gyr.edit.title'))
      click_on I18n.t('questions.triage.gyr_tile.choose_gyr')

      expect(page).to have_selector("h1", text: I18n.t('questions.triage_gyr_ids.edit.title'))
      click_on I18n.t('questions.triage_gyr_ids.edit.yes_i_have_id')

      expect(page).to have_text I18n.t('views.questions.environment_warning.title')
      click_on I18n.t('general.continue_example')

      expect(page).to have_selector("h1", text: "Just a few simple steps to file!")
      click_on "Continue"

      expect(page).to have_selector("h1", text: "First, let's get some basic information.")
      fill_in "What is your preferred first name?", with: "Gary"
      fill_in "Phone number", with: "8286345533"
      fill_in "Confirm phone number", with: "828-634-5533"
      fill_in "ZIP code", with: "20121"
      click_on "Continue"

      # don't show SSN/ITIN page

      expect(page).to have_selector("h1", text: I18n.t("views.questions.backtaxes.title"))
      check "#{TaxReturn.current_tax_year}"
      click_on "Continue"

      expect(page).to have_selector("h1", text: "Let's get started")
      expect(page).to have_text("We’ll start by asking about your situation in #{TaxReturn.current_tax_year}.")
      click_on "Continue"

      # next page is interview time preferences
      expect(page).to have_selector("h1", text: I18n.t("views.questions.interview_scheduling.title"))

      click_on "Continue"

      # Notification Preference
      check I18n.t('views.questions.notification_preference.options.email_notification_opt_in')
      check I18n.t('views.questions.notification_preference.options.sms_notification_opt_in')
      click_on I18n.t('general.continue')

      # Phone number can text
      expect(page).to have_text("(828) 634-5533")
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
      select I18n.t("date.month_names")[3], from: "consent_form_birth_date_month"
      select "5", from: "consent_form_birth_date_day"
      select "1971", from: "consent_form_birth_date_year"
      click_on I18n.t("views.questions.consent.cta")
      expect(page).to have_text("You have the option to consent to the following:")
    end

  end

  context "when the itin applicant has a duplicate" do
    let!(:duplicated_itin_app) do
      create(
        :intake,
        primary_birth_date: Date.new(1971, 3, 5),
        email_address: "gary.gardengnome@example.green",
        primary_consented_to_service: "yes",
        primary_consented_to_service_at: 15.minutes.ago,
        triage: (create :triage, id_type: "need_itin_help")
      )
    end

    scenario "the client fills out triage and beginning of intake, but after consent gets sent to returning client page" do
      answer_gyr_triage_questions({
                                      filing_status: "single",
                                      income_level: "1_to_12500",
                                      id_type: "need_itin_help",
                                      doc_type: "need_help",
                                      filed_past_years: [],
                                      income_type_options: ['none_of_the_above']
                                  })

      expect(page).to have_selector("h1", text: I18n.t('questions.triage_gyr.edit.title'))
      click_on I18n.t('questions.triage.gyr_tile.choose_gyr')

      expect(page).to have_selector("h1", text: I18n.t('questions.triage_gyr_ids.edit.title'))
      click_on I18n.t('questions.triage_gyr_ids.edit.yes_i_have_id')

      expect(page).to have_text I18n.t('views.questions.environment_warning.title')
      click_on I18n.t('general.continue_example')

      expect(page).to have_selector("h1", text: "Just a few simple steps to file!")
      click_on "Continue"

      expect(page).to have_selector("h1", text: "First, let's get some basic information.")
      fill_in "What is your preferred first name?", with: "Gary"
      fill_in "Phone number", with: "8286345533"
      fill_in "Confirm phone number", with: "828-634-5533"
      fill_in "ZIP code", with: "20121"
      click_on "Continue"

      # don't show SSN/ITIN page

      expect(page).to have_selector("h1", text: I18n.t("views.questions.backtaxes.title"))
      check "#{TaxReturn.current_tax_year}"
      click_on "Continue"

      expect(page).to have_selector("h1", text: "Let's get started")
      expect(page).to have_text("We’ll start by asking about your situation in #{TaxReturn.current_tax_year}.")
      click_on "Continue"

      # next page is interview time preferences
      expect(page).to have_selector("h1", text: I18n.t("views.questions.interview_scheduling.title"))

      click_on "Continue"

      # Notification Preference
      check I18n.t('views.questions.notification_preference.options.email_notification_opt_in')
      check I18n.t('views.questions.notification_preference.options.sms_notification_opt_in')
      click_on I18n.t('general.continue')

      # Phone number can text
      expect(page).to have_text("(828) 634-5533")
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
      select I18n.t("date.month_names")[3], from: "consent_form_birth_date_month"
      select "5", from: "consent_form_birth_date_day"
      select "1971", from: "consent_form_birth_date_year"
      click_on I18n.t("views.questions.consent.cta")
      expect(page).to have_text(I18n.t("views.questions.returning_client.title"))
    end
  end
end
