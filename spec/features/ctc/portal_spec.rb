require "rails_helper"

RSpec.feature "CTC Intake", :js, :active_job, requires_default_vita_partners: true do
  module CtcPortalHelper
    def log_in_to_ctc_portal
      visit "/en/portal/login"

      expect(page).to have_selector("h1", text: I18n.t("portal.client_logins.new.title"))
      fill_in "Email address", with: "mango@example.com"
      click_on "Send code"

      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      expect(mail.html_part.body.to_s).to have_text("Your six-digit verification code for GetCTC is: ")
      code = mail.html_part.body.to_s.match(/Your six-digit verification code for GetCTC is: <strong> (\d+)/)[1]
      fill_in "Enter 6 digit code", with: code
      click_on "Verify"
      expect(page).to have_selector("h1", text: "Authentication needed to continue.")
      fill_in "Client ID or Last 4 of SSN/ITIN", with: intake.client.id
      click_on "Continue"
    end
  end
  include CtcPortalHelper

  let(:only_product_year_that_supports_login) { 2022 }
  let!(:intake) { create :ctc_intake, email_address: "mango@example.com", email_notification_opt_in: "yes", product_year: only_product_year_that_supports_login }

  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
    allow_any_instance_of(EfileSecurityInformation).to receive(:timezone).and_return("America/Chicago")
  end

  context "when the client has not verified" do
    before do
      intake.update(email_address_verified_at: nil)
    end

    scenario "they get the no match found email" do
      visit "/en/portal/login"

      expect(page).to have_selector("h1", text: I18n.t("portal.client_logins.new.title"))
      fill_in "Email address", with: "mango@example.com"
      click_on "Send code"

      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      expect(mail.html_part.body.to_s).to have_text("It looks like you attempted to sign in to GetCTC, but we did not find any matching contact information.")
    end
  end

  context "when the client has verified their contact info" do
    before do
      intake.update(email_address_verified_at: DateTime.now)
    end

    context "ctc login is closed for the season" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:open_for_ctc_login?).and_return(false)
        allow_any_instance_of(ApplicationController).to receive(:open_for_ctc_intake?).and_return(false)
      end

      it "redirects to the ctc home" do
        visit "/en/portal/login"

        expect(page).not_to have_selector("h1", text: I18n.t('portal.client_logins.new.title'))
      end
    end

    context "efile submission is status accepted, there is a 1040 to download" do
      before do
        es = create(:efile_submission, :accepted, tax_return: create(:ctc_tax_return, client: intake.client))
        create(:document, document_type: DocumentTypes::Form1040.key, tax_return: es.tax_return, client: es.tax_return.client)
      end

      scenario "a client sees their submission status and can download their tax return" do
        log_in_to_ctc_portal

        expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
        expect(page).to have_link I18n.t("views.ctc.portal.home.download_tax_return")
      end
    end
  end
end
