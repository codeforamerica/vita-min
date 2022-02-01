require "rails_helper"

feature "Intake Routing Spec", :flow_explorer_screenshot, :active_job do
  include MockTwilio

  def fill_out_notification_preferences
    # Notification Preference
    check "Email Me"
    check "Text Me"
    click_on "Continue"

    # Phone number can text
    expect(page).to have_text("(415) 888-0088")
    click_on "No"

    # Phone number
    expect(page).to have_selector("h1", text: "Please share your cell phone number.")
    fill_in "Cell phone number", with: "(415) 553-7865"
    fill_in "Confirm cell phone number", with: "+1415553-7865"
    click_on "Continue"

    # Verify cell phone contact
    perform_enqueued_jobs
    sms = FakeTwilioClient.messages.last
    code = sms.body.to_s.match(/\s(\d{6})[.]/)[1]
    fill_in "Enter 6 digit code", with: code
    click_on "Verify"

    # Email
    fill_in "Email address", with: "gary.gardengnome@example.green"
    fill_in "Confirm email address", with: "gary.gardengnome@example.green"
    click_on "Continue"

    # Verify email contact
    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]
    fill_in "Enter 6 digit code", with: code
    click_on "Verify"

    # Consent form
    fill_in "Legal first name", with: "Gary"
    fill_in "Legal last name", with: "Gnome"
    fill_in I18n.t("attributes.primary_ssn"), with: "123456789"
    fill_in I18n.t("attributes.confirm_primary_ssn"), with: "123456789"
    select "March", from: "Month"
    select "5", from: "Day"
    select "1971", from: "Year"
    click_on "I agree"

    # Optional consent form
    expect(page).to have_selector("h1", text: "A few more things...")
    expect(page).to have_checked_field("Consent to Use")
    expect(page).to have_link("Consent to Use", href: consent_to_use_path)
    expect(page).to have_checked_field("Consent to Disclose")
    expect(page).to have_link("Consent to Disclose", href: consent_to_disclose_path)
    expect(page).to have_checked_field("Relational EFIN")
    expect(page).to have_link("Relational EFIN", href: relational_efin_path)
    expect(page).to have_checked_field("Global Carryforward")
    expect(page).to have_link("Global Carryforward", href: global_carryforward_path)
    uncheck "Global Carryforward"
    click_on "Continue"
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

    expect(page).to have_text "Free tax filing, made simple."

    # clients with matching vita partner source param skip triage questions
    click_on "Get started", id: "firstCta"
    expect(page).to have_text "Welcome"
    click_on "Continue"

    expect(page).to have_text I18n.t("views.questions.backtaxes.title")
    check "2020"
    click_on "Continue"

    expect(Intake.last.source).to eq "cobra"
    expect(page).to have_text "Thanks for visiting the GetYourRefund demo application!"
    click_on "Continue to example"

    expect(page).to have_text "Let's get started"
    click_on "Continue"

    expect(page).to have_text "Just a few simple steps to file!"
    click_on "Continue"

    expect(page).to have_text "let's get some basic information"
    fill_in "What is your preferred first name?", with: "Betty Banana"
    fill_in "ZIP code", with: zip_code
    fill_in "Phone number", with: "415-888-0088"
    fill_in "Confirm phone number", with: "415-888-0088"
    click_on "Continue"

    fill_in "Do you have any time preferences for your interview phone call?", with: "During school hours"
    click_on "Continue"

    fill_out_notification_preferences

    expect(page.html).to have_text "Our team at Cobra Academy is here to help!"
  end

  scenario "routing by zip code" do
    visit "/questions/backtaxes"

    expect(page).to have_text I18n.t("views.questions.backtaxes.title")
    check "2020"
    click_on "Continue"

    expect(Intake.last.source).to eq nil
    expect(page).to have_text "Thanks for visiting the GetYourRefund demo application!"
    click_on "Continue to example"

    expect(page).to have_text "Let's get started"
    click_on "Continue"

    expect(page).to have_text "Just a few simple steps to file!"
    click_on "Continue"

    expect(page).to have_text "let's get some basic information"
    fill_in "What is your preferred first name?", with: "Minerva Mcgonagall"
    fill_in "ZIP code", with: zip_code
    fill_in "Phone number", with: "415-888-0088"
    fill_in "Confirm phone number", with: "415-888-0088"
    click_on "Continue"

    fill_in "Do you have any time preferences for your interview phone call?", with: "During school hours"
    click_on "Continue"

    fill_out_notification_preferences

    expect(page.html).to have_text "Our team at Diagon Alley is here to help!"
  end

  scenario "routing by state" do
    visit "/questions/backtaxes"

    expect(page).to have_text I18n.t("views.questions.backtaxes.title")
    check "2020"
    click_on "Continue"

    expect(Intake.last.source).to eq nil
    expect(page).to have_text "Thanks for visiting the GetYourRefund demo application!"
    click_on "Continue to example"

    expect(page).to have_text "Let's get started"
    click_on "Continue"

    expect(page).to have_text "Just a few simple steps to file!"
    click_on "Continue"

    expect(page).to have_text "let's get some basic information"
    fill_in "What is your preferred first name?", with: "Luna Lovegood"
    fill_in "ZIP code", with: "28806"
    fill_in "Phone number", with: "415-888-0088"
    fill_in "Confirm phone number", with: "415-888-0088"
    click_on "Continue"

    fill_in "Do you have any time preferences for your interview phone call?", with: "During school hours"
    click_on "Continue"

    fill_out_notification_preferences

    expect(page.html).to have_text "Our team at Hogwarts is here to help!"
  end
  context "at capacity but overflow site exists" do
    let!(:default_vita_partner) { create :organization, name: "Default Organization", national_overflow_location: true }

    before do
      expected_state_vita_partner.update(capacity_limit: 0)
    end

    scenario "routes to national partner" do
      visit "/questions/backtaxes"

      expect(page).to have_text I18n.t("views.questions.backtaxes.title")
      check "2020"
      click_on "Continue"

      expect(Intake.last.source).to eq nil
      expect(page).to have_text "Thanks for visiting the GetYourRefund demo application!"
      click_on "Continue to example"

      expect(page).to have_text "Let's get started"
      click_on "Continue"

      expect(page).to have_text "Just a few simple steps to file!"
      click_on "Continue"

      expect(page).to have_text "let's get some basic information"
      fill_in "What is your preferred first name?", with: "Luna Lovegood"
      fill_in "ZIP code", with: "28806"
      fill_in "Phone number", with: "415-888-0088"
      fill_in "Confirm phone number", with: "415-888-0088"
      click_on "Continue"

      fill_in "Do you have any time preferences for your interview phone call?", with: "During school hours"
      click_on "Continue"

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

      expect(page).to have_text I18n.t("views.questions.backtaxes.title")
      check "2020"
      click_on "Continue"

      expect(Intake.last.source).to eq nil
      expect(page).to have_text "Thanks for visiting the GetYourRefund demo application!"
      click_on "Continue to example"

      expect(page).to have_text "Let's get started"
      click_on "Continue"

      expect(page).to have_text "Just a few simple steps to file!"
      click_on "Continue"

      expect(page).to have_text "let's get some basic information"
      fill_in "What is your preferred first name?", with: "Luna Lovegood"
      fill_in "ZIP code", with: "28806"
      fill_in "Phone number", with: "415-888-0088"
      fill_in "Confirm phone number", with: "415-888-0088"
      click_on "Continue"

      fill_in "Do you have any time preferences for your interview phone call?", with: "During school hours"
      click_on "Continue"

      fill_out_notification_preferences

      expect(page.html).to have_text I18n.t("views.questions.at_capacity.title")
    end
  end
end
