require "rails_helper"

RSpec.feature "Web Intake Client matches with partner who is at capacity", :flow_explorer_screenshot do
  include(Module.new do
    def intake_up_to_at_capacity_page
      # at first, sees at capacity page when resuming.
      # After updating routing method, does not see at capacity page.
      visit personal_info_questions_path
      fill_out_personal_information(name: "Gary", zip_code: "19143", birth_date: Date.parse("1983-10-12"), phone_number: "555-555-1212")

      expect(page).to have_selector("h1", text: "Please provide your taxpayer identification information.")
      select "Social Security Number (SSN)", from: "Identification Type"
      fill_in I18n.t("attributes.primary_ssn"), with: "123-45-6789"
      fill_in I18n.t("attributes.confirm_primary_ssn"), with: "123-45-6789"
      click_on "Continue"

      current_tax_year = MultiTenantService.new(:gyr).current_tax_year
      expect(page).to have_selector("h1", text: I18n.t("views.questions.backtaxes.title"))
      check "#{current_tax_year}"
      click_on "Continue"

      expect(page).to have_selector("h1", text: I18n.t('views.questions.start_with_current_year.title', year: current_tax_year))
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
      code = mail.html_part.body.to_s.match(/(\d{6})[.]/)[1]
      fill_in "Enter 6 digit code", with: code
      click_on "Verify"

      expect(page).to have_selector("h1", text: I18n.t('views.questions.consent.title'))
      fill_in I18n.t("views.questions.consent.primary_first_name"), with: "Gary"
      fill_in I18n.t("views.questions.consent.primary_last_name"), with: "Gnome"
      click_on I18n.t("views.questions.consent.cta")
    end
  end)

  context "when there are no partners with capacity" do
    before do
      routing_service_double = instance_double(PartnerRoutingService)

      allow(routing_service_double).to receive(:routing_method).and_return :at_capacity
      allow(routing_service_double).to receive(:determine_partner).and_return nil
      allow(PartnerRoutingService).to receive(:new).and_return routing_service_double
      intake_up_to_at_capacity_page
    end

    it "shows an at capacity page and logs the client out" do
      expect(page).to have_selector("h1", text: I18n.t("views.questions.at_capacity.title"))
      expect(page).to have_text I18n.t("views.questions.at_capacity.body_html")[1]
      expect(page).not_to have_text("Logout")
      expect(Intake.last.viewed_at_capacity).to be_truthy
      click_on "Return to homepage"
    end

    xit "allows the client to choose DIY" do
      click_on I18n.t("views.questions.at_capacity.continue_to_diy")

      expect(page).to have_selector("h1", text: "File taxes on your own")
      expect(Intake.last.continued_at_capacity).to be_falsey
    end

    it "allows the client to log in again, start at the consent page, and see the at capacity page" do
      within ".toolbar" do
        click_on "Login"
      end
      fill_in "Email address", with: "gary.gardengnome@example.green"
      click_on I18n.t("portal.client_logins.new.send_code")
      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]

      fill_in "Enter 6 digit code", with: code
      click_on "Verify"

      fill_in "Client ID or Last 4 of SSN/ITIN", with: "6789"
      click_on "Continue"

      expect(page).to have_text "Welcome back"
      click_on I18n.t("portal.portal.home.document_link.complete_tax_questions")
      expect(page).to have_selector("h1", text: I18n.t('views.questions.consent.title'))
      click_on I18n.t("views.questions.consent.cta")
      expect(page).to have_content "GetYourRefund's tax preparation partners are currently at capacity."
    end

    context "when a Hub user has assigned the client to a partner" do
      it "allows the client past At Capacity if a Hub user assigned them to a partner" do
        ActiveRecord::Base.transaction do
          UpdateClientVitaPartnerService.new(clients: [Client.last], vita_partner_id: create(:organization).id).update!
        end
        within ".toolbar" do
          click_on "Login"
        end
        fill_in "Email address", with: "gary.gardengnome@example.green"
        click_on I18n.t("portal.client_logins.new.send_code")
        perform_enqueued_jobs
        mail = ActionMailer::Base.deliveries.last
        code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]

        fill_in "Enter 6 digit code", with: code
        click_on "Verify"

        fill_in "Client ID or Last 4 of SSN/ITIN", with: "6789"
        click_on "Continue"

        expect(page).to have_text "Welcome back"
        click_on I18n.t("portal.portal.home.document_link.complete_tax_questions")
        expect(page).to have_selector("h1", text: I18n.t("views.questions.consent.title"))
      end
    end
  end

  context "when a vita partner becomes available after the client has seen the at capacity page" do
    let(:overflow_organization) { create :organization }

    it "allows the client to log in, start from the consent page, and get routed to a vita partner" do
      routing_service_double = instance_double(PartnerRoutingService)
      allow(PartnerRoutingService).to receive(:new).and_return routing_service_double

      # no one has capacity
      allow(routing_service_double).to receive(:routing_method).and_return :at_capacity
      allow(routing_service_double).to receive(:determine_partner).and_return nil

      # first time client tries to do intake
      intake_up_to_at_capacity_page

      # national overflow becomes available
      allow(routing_service_double).to receive(:routing_method).and_return :national_overflow
      allow(routing_service_double).to receive(:determine_partner).and_return overflow_organization

      # client comes back through the portal
      within ".toolbar" do
        click_on "Login"
      end
      fill_in "Email address", with: "gary.gardengnome@example.green"
      click_on I18n.t("portal.client_logins.new.send_code")
      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]

      fill_in "Enter 6 digit code", with: code
      click_on "Verify"

      fill_in "Client ID or Last 4 of SSN/ITIN", with: "6789"
      click_on "Continue"

      expect(page).to have_text "Welcome back"
      click_on I18n.t("portal.portal.home.document_link.complete_tax_questions")
      expect(page).to have_selector("h1", text: I18n.t('views.questions.consent.title'))

      expect do
        click_on I18n.t("views.questions.consent.cta")
      end.to change { Client.last.vita_partner }.to(overflow_organization)

      expect(page).to have_selector("h1", text: I18n.t("views.questions.optional_consent.title"))
    end
  end
end
