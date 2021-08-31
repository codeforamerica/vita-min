require "rails_helper"

RSpec.feature "CTC Intake", :js, :active_job do
  module CtcPortalHelper
    def log_in_to_ctc_portal
      visit "/en/portal/login"

      expect(page).to have_selector("h1", text: "To view your progress, we’ll send you a secure code.")
      fill_in "Email address", with: "mango@example.com"
      click_on "Send code"

      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      expect(mail.html_part.body.to_s).to have_text("Your 6-digit GetCTC verification code is: ")
      code = mail.html_part.body.to_s.match(/Your 6-digit GetCTC verification code is: (\d+)/)[1]
      fill_in "Enter 6 digit code", with: code
      click_on "Verify"
      expect(page).to have_selector("h1", text: "Authentication needed to continue.")
      fill_in "Client ID or Last 4 of SSN/ITIN", with: intake.client.id
      click_on "Continue"
    end
  end
  include CtcPortalHelper

  let!(:intake) { create :ctc_intake, email_address: "mango@example.com", email_notification_opt_in: "yes" }

  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  context "when the client has not verified" do
    before do
      intake.update(email_address_verified_at: nil)
    end

    scenario "they get the no match found email" do
      visit "/en/portal/login"

      expect(page).to have_selector("h1", text: "To view your progress, we’ll send you a secure code.")
      fill_in "Email address", with: "mango@example.com"
      click_on "Send code"

      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      expect(mail.html_part.body.to_s).to have_text("It looks like you attempted to sign in to GetCTC, but we did not find any matching contact information.")
    end
  end

  context "when the client has verified the contact, intake is in progress" do
    let!(:intake) { create :ctc_intake, client: create(:client, tax_returns: [build(:tax_return, year: 2020)]), email_address: "mango@example.com"}
    before do
      intake.update(email_address_verified_at: DateTime.now, current_step: "/en/questions/spouse-info")
    end

    scenario "a client sees and can click on a link to continue their intake" do
      log_in_to_ctc_portal

      expect(page).to have_selector("h1", text: "Thank you for filing with GetCTC!")
      expect(page).to have_text "More information needed"
      expect(page).to have_text "We need more information from you before we can file your return."
      click_on "Complete CTC form"
      expect(page).to have_text "Tell us about your spouse"
    end
  end

  context "when the client has verified the contact, efile submission is status new" do
    before do
      intake.update(email_address_verified_at: DateTime.now, current_step: "/en/questions/spouse-info")
      create(:efile_submission, tax_return: create(:tax_return, client: intake.client, year: 2020))
    end

    scenario "a client sees and can click on a link to continue their intake" do
      log_in_to_ctc_portal

      expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
      expect(page).to have_text I18n.t("views.ctc.portal.home.status.new.label")
      expect(page).to have_text I18n.t("views.ctc.portal.home.status.new.message")
    end
  end

  context "when the client has verified the contact, efile submission is status preparing" do
    before do
      intake.update(email_address_verified_at: DateTime.now)
      create(:efile_submission, :preparing, tax_return: create(:tax_return, client: intake.client, year: 2020))
    end

    scenario "a client sees and can click on a link to continue their intake" do
      log_in_to_ctc_portal

      expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
      expect(page).to have_text I18n.t("views.ctc.portal.home.status.preparing.label")
      expect(page).to have_text I18n.t("views.ctc.portal.home.status.preparing.message")
    end
  end

  context "when the client has verified the contact, efile submission is status failed" do
    before do
      intake.update(email_address_verified_at: DateTime.now)
      create(:efile_submission, :failed, tax_return: create(:tax_return, client: intake.client, year: 2020))
    end

    scenario "a client sees and can click on a link to continue their intake" do
      log_in_to_ctc_portal

      expect(page).to have_selector("h1", text: "Thank you for filing with GetCTC!")
      expect(page).to have_text "Submission error"
      expect(page).to have_text "Our team is investigating a technical error with your return. Once we resolve this error, we'll resubmit your return."
    end
  end

  context "when the client has verified the contact, efile submission is status investigating" do
    before do
      intake.update(email_address_verified_at: DateTime.now)
      es = create(:efile_submission, :failed, tax_return: create(:tax_return, client: intake.client, year: 2020))
      es.transition_to!(:investigating)

    end
    scenario "a client sees information about the previous transition to failed" do
      log_in_to_ctc_portal

      expect(page).to have_selector("h1", text: "Thank you for filing with GetCTC!")
      expect(page).to have_text "Submission error"
      expect(page).to have_text "Our team is investigating a technical error with your return. Once we resolve this error, we'll resubmit your return. Please expect an update within 3 business days."
    end

  end

  context "when the client has verified the contact, efile submission is status transmitted" do
    before do
      intake.update(email_address_verified_at: DateTime.now)
      create(:efile_submission, :transmitted, tax_return: create(:tax_return, client: intake.client, year: 2020))
    end

    scenario "a client sees and can click on a link to continue their intake" do
      log_in_to_ctc_portal

      expect(page).to have_selector("h1", text: "Thank you for filing with GetCTC!")
      expect(page).to have_text "Electronically filed"
      expect(page).to have_text I18n.t("views.ctc.portal.home.status.transmitted.message")
    end
  end

  context "when the client has verified the contact, efile submission is status accepted, there is a 1040 to download" do
    before do
      intake.update(email_address_verified_at: DateTime.now)
      es = create(:efile_submission, :accepted, tax_return: create(:tax_return, client: intake.client, year: 2020))
      create(:document, document_type: DocumentTypes::Form1040.key, tax_return: es.tax_return, client: es.tax_return.client)
    end

    scenario "a client sees and can click on a link to continue their intake" do
      log_in_to_ctc_portal

      expect(page).to have_selector("h1", text: "Thank you for filing with GetCTC!")
      expect(page).to have_text "Accepted"
      expect(page).to have_text "Your return has been accepted by the IRS. You should receive a payment within 1-4 weeks."
      expect(page).to have_link "Download my tax return"
    end
  end

  context "when the client has verified the contact, efile submission is status rejected" do
    let(:qualifying_child) { build(:qualifying_child, ssn: "111-22-3333") }
    let(:dependent_to_delete) { build(:qualifying_child, first_name: "UniqueLookingName", ssn: "111-22-4444") }
    let!(:intake) do
      create(
        :ctc_intake,
        :with_address,
        :with_contact_info,
        :with_ssns,
        email_address: "mango@example.com",
        email_notification_opt_in: "yes",
        spouse_first_name: "Eva",
        spouse_last_name: "Hesse",
        spouse_birth_date: Date.new(1929, 9, 2),
        dependents: [qualifying_child, dependent_to_delete]
      )
    end
    let!(:efile_submission) { create(:efile_submission, :rejected, :ctc, :with_errors, tax_return: build(:tax_return, :ctc, filing_status: "married_filing_jointly", client: intake.client, year: 2020, status: "intake_in_progress")) }

    before do
      intake.update(email_address_verified_at: DateTime.now)
    end

    scenario "a client can correct their information" do
      log_in_to_ctc_portal

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.portal.home.title'))
      expect(page).to have_text "Rejected"

      click_on I18n.t("views.ctc.portal.home.correct_info")
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.portal.edit_info.title'))

      click_on I18n.t('general.back')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.portal.home.title'))

      click_on I18n.t("views.ctc.portal.home.correct_info")

      within ".primary-info" do
        click_on I18n.t('general.edit').downcase
      end
      fill_in I18n.t('views.ctc.questions.legal_consent.first_name'), with: "Mangonada"
      click_on I18n.t('general.save')

      expect(page).to have_text "Mangonada"

      within ".address-info" do
        click_on I18n.t('general.edit').downcase
      end
      fill_in I18n.t("views.questions.mailing_address.street_address"), with: "123 Sandwich Lane"
      click_on I18n.t('general.save')

      expect(page).to have_text "123 Sandwich Lane"

      within ".spouse-info" do
        click_on I18n.t('general.edit').downcase
      end
      fill_in I18n.t("views.ctc.questions.spouse_info.spouse_first_name"), with: "Pomelostore"
      click_on I18n.t('general.save')

      expect(page).to have_text "Pomelostore"

      within "#dependent_#{qualifying_child.id}" do
        click_on I18n.t('general.edit').downcase
      end
      fill_in I18n.t('views.ctc.questions.dependents.info.first_name'), with: "Papaya"
      click_on I18n.t('general.save')

      expect(page).to have_text "Papaya"

      within "#dependent_#{dependent_to_delete.id}" do
        click_on I18n.t('general.edit').downcase
      end
      click_on I18n.t('views.ctc.questions.dependents.tin.remove_person')
      click_on I18n.t('views.ctc.questions.dependents.remove_dependent.remove_button')

      expect(dependent_to_delete.reload.soft_deleted_at).to be_truthy
      expect(page).not_to have_text dependent_to_delete.first_name

      expect(page).to have_selector("p", text: I18n.t("views.ctc.portal.edit_info.help_text"))
      click_on I18n.t("views.ctc.portal.home.contact_us")
      click_on I18n.t("general.back")
      click_on I18n.t('views.ctc.portal.edit_info.resubmit')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.portal.home.title'))
      expect(page).to have_text I18n.t('views.ctc.portal.home.status.preparing.label')

      # Go look for the note as an admin
      Capybara.current_session.reset!

      allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(false)
      login_as create :admin_user

      visit hub_clients_path

      within ".client-table" do
        click_on intake.preferred_name
      end

      click_on I18n.t('hub.clients.navigation.client_notes')

      expect(page).to have_content("Mangonada")
      expect(page).to have_content("Papaya")
      expect(page).to have_content("Pomelostore")
      expect(page).to have_content("123 Sandwich Lane")

      expect(page).to have_content("Client removed Dependent ##{dependent_to_delete.id}")
      expect(page).to have_content("Client initiated resubmission of their tax return.")
    end

    scenario "a client sees and can click on a link to continue their intake" do
      log_in_to_ctc_portal

      expect(page).to have_selector("h1", text: "Thank you for filing with GetCTC!")
      expect(page).to have_text "Rejected"
      expect(page).to have_text "IND-189"
      expect(page).to have_text "'DeviceId' in 'AtSubmissionCreationGrp' in 'FilingSecurityInformation' in the Return Header must have a value."
      # only show the first error to the user so as not to overwhelm them
      expect(page).not_to have_text "IND-190: 'DeviceId' in 'AtSubmissionFilingGrp' in 'FilingSecurityInformation' in the Return Header must have a value."
      expect(page).to have_text "Please send us a message with questions or corrections using the \"Contact Us\" button below."
      click_on "Contact us"
      expect(page).to have_selector "h1", text: "Message your tax preparers"
      fill_in "What's on your mind?", with: "I have some questions about my tax return."
      click_on "Send message"
      expect(page).to have_text "Message sent! Responses will be sent by email to mango@example.com."
    end
  end

  context "when the client has verified the contact, efile submission is status cancelled" do
    before do
      intake.update(email_address_verified_at: DateTime.now)
      es = create(:efile_submission, :rejected, :with_errors, tax_return: create(:tax_return, client: intake.client, year: 2020))
      es.transition_to!(:cancelled)
    end

    scenario "a client sees information about their cancelled submission" do
      log_in_to_ctc_portal

      expect(page).to have_selector("h1", text: "Thank you for filing with GetCTC!")
      expect(page).to have_text I18n.t("views.ctc.portal.home.status.rejected.label")
      expect(page).to have_text I18n.t("views.ctc.portal.home.status.cancelled.message")
      click_on "Contact us"
      expect(page).to have_selector "h1", text: "Message your tax preparer"
      fill_in "What's on your mind?", with: "I have some questions about my tax return."
      click_on "Send message"
      expect(page).to have_text "Message sent! Responses will be sent by email to mango@example.com."
    end
  end
end
