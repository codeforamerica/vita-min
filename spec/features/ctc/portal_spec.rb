require "rails_helper"

RSpec.feature "CTC Intake", :js, :active_job, requires_default_vita_partners: true do
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
    allow_any_instance_of(EfileSecurityInformation).to receive(:timezone).and_return("America/Chicago")
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
        expect(page).to have_text(I18n.t('views.ctc_pages.home.closing_date_not_open'))
      end
    end

    context "intake is in progress" do
      let!(:intake) { create :ctc_intake, client: create(:client, tax_returns: [build(:tax_return, year: 2021)]), email_address: "mango@example.com" }
      before do
        intake.update(current_step: "/en/questions/spouse-info")
      end

      scenario "a client sees and can click on a link to continue their intake" do
        log_in_to_ctc_portal

        expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
        expect(page).to have_text "More information needed"
        expect(page).to have_text "We need more information from you before we can file your return."
        click_on "Complete CTC form"
        expect(page).to have_text "Tell us about your spouse"
      end
    end

    context "efile submission is status new" do
      before do
        intake.update(current_step: "/en/questions/spouse-info")
        create(:efile_submission, tax_return: create(:tax_return, client: intake.client, year: 2021))
      end

      scenario "a client sees and can click on a link to continue their intake" do
        log_in_to_ctc_portal

        expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
        expect(page).to have_text I18n.t("views.ctc.portal.home.status.new.label")
        expect(page).to have_text I18n.t("views.ctc.portal.home.status.new.message")
      end
    end

    context "efile submission is status preparing" do
      before do
        create(:efile_submission, :preparing, tax_return: create(:tax_return, client: intake.client, year: 2021))
      end

      scenario "a client sees and can click on a link to continue their intake" do
        log_in_to_ctc_portal

        expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
        expect(page).to have_text I18n.t("views.ctc.portal.home.status.preparing.label")
        expect(page).to have_text I18n.t("views.ctc.portal.home.status.preparing.message")
      end
    end

    context "efile submission is status failed" do
      before do
        create(:efile_submission, :failed, tax_return: create(:tax_return, client: intake.client, year: 2021))
      end

      scenario "a client sees their submission status" do
        log_in_to_ctc_portal

        expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
        expect(page).to have_text I18n.t("views.ctc.portal.home.status.failed.label")
        expect(page).to have_text "Our team is investigating a technical error with your return. Once we resolve this error, we'll resubmit your return."
      end

      scenario "a client can upload a document" do
        log_in_to_ctc_portal

        expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
        expect(page).to have_text I18n.t("views.ctc.portal.home.status.failed.label")

        expect(page).to have_text I18n.t("views.ctc.portal.home.submit_documents")
        expect(intake.client.documents.where(document_type: "Other").length).to eq 0

        click_link I18n.t("views.ctc.portal.home.submit_documents")
        expect(page).to have_text I18n.t("views.documents.additional_documents.title")

        upload_file("requested_document_upload_form[document]", Rails.root.join("spec", "fixtures", "files", "test-pattern.png"))
        expect(page).to have_content("test-pattern.png")

        expect(intake.client.documents.where(document_type: "Other").length).to eq 1
        page.accept_alert 'Are you sure you want to remove "test-pattern.png"?' do
          click_on I18n.t("general.remove")
        end

        expect(page).to have_text I18n.t("views.documents.additional_documents.title")
        expect(intake.client.documents.where(document_type: "Other").length).to eq 0

        click_on I18n.t("general.continue")
        expect(page).to have_text I18n.t("views.ctc.portal.home.title")
        click_on I18n.t("views.ctc.portal.home.submit_documents")

        expect(page).not_to have_content("test-pattern.png")

        expect(page).to have_text I18n.t("views.documents.additional_documents.title")
        expect(page).not_to have_text I18n.t("views.layouts.document_upload.dont_have")
        click_on I18n.t("general.back")
      end
    end

    context "efile submission is status investigating" do
      before do
        es = create(:efile_submission, :failed, tax_return: create(:tax_return, client: intake.client, year: 2021))
        es.transition_to!(:investigating)
      end

      scenario "a client sees information about the previous transition to failed" do
        log_in_to_ctc_portal

        expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
        expect(page).to have_text I18n.t("views.ctc.portal.home.status.failed.label")
        expect(page).to have_text I18n.t("views.ctc.portal.home.status.failed.message")
      end
    end

    context "efile submission is status transmitted" do
      before do
        create(:efile_submission, :transmitted, tax_return: create(:tax_return, client: intake.client, year: 2021))
      end

      scenario "a client sees their submission status" do
        log_in_to_ctc_portal

        expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
        expect(page).to have_text "Electronically filed"
        expect(page).to have_text I18n.t("views.ctc.portal.home.status.transmitted.message")
      end
    end

    context "efile submission is status accepted, there is a 1040 to download" do
      before do
        es = create(:efile_submission, :accepted, tax_return: create(:tax_return, client: intake.client, year: 2021))
        create(:document, document_type: DocumentTypes::Form1040.key, tax_return: es.tax_return, client: es.tax_return.client)
      end

      scenario "a client sees their submission status and can download their tax return" do
        log_in_to_ctc_portal

        expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
        expect(page).to have_text I18n.t("views.ctc.portal.home.status.accepted.label")
        expect(page).to have_text I18n.t("views.ctc.portal.home.status.accepted.message")
        expect(page).to have_link I18n.t("views.ctc.portal.home.download_tax_return")
      end
    end

    context "efile submission is status rejected" do
      let(:qualifying_child) { build(:qualifying_child, ssn: "111-22-3333") }
      let(:dependent_to_delete) { build(:qualifying_child, first_name: "UniqueLookingName", ssn: "111-22-4444") }
      let!(:intake) do
        create(
          :ctc_intake,
          :with_address,
          :with_contact_info,
          :with_ssns,
          :with_bank_account,
          email_address: "mango@example.com",
          email_notification_opt_in: "yes",
          refund_payment_method: "direct_deposit",
          spouse_first_name: "Eva",
          spouse_last_name: "Hesse",
          spouse_birth_date: Date.new(1929, 9, 2),
          dependents: [qualifying_child, dependent_to_delete]
        )
      end
      let!(:efile_submission) { create(:efile_submission, :rejected, :ctc, :with_errors, tax_return: build(:tax_return, :intake_in_progress, :ctc, filing_status: "married_filing_jointly", client: intake.client, year: 2021)) }

      scenario "a client can correct their information" do
        log_in_to_ctc_portal

        expect(page).to have_selector("h1", text: I18n.t('views.ctc.portal.home.title'))
        expect(page).to have_text "Rejected"

        click_on I18n.t("views.ctc.portal.home.correct_info")
        expect(page).to have_selector("h1", text: I18n.t('views.ctc.portal.edit_info.title'))

        click_on I18n.t('general.back')
        expect(page).to have_selector("h1", text: I18n.t('views.ctc.portal.home.title'))

        click_on I18n.t("views.ctc.portal.home.correct_info")

        # Can't resubmit until you have made a meaningful edit
        expect(page).to have_selector("button:disabled", text: I18n.t('views.ctc.portal.edit_info.resubmit'))

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

        expect(page).to have_text "Your bank information"

        within ".bank-account-info" do
          click_on I18n.t("general.change")
        end

        expect(page).to have_text I18n.t("views.ctc.questions.refund_payment.title")
        choose I18n.t("views.ctc.questions.refund_payment.direct_deposit")
        click_on I18n.t('general.continue')

        expect(page).to have_text "Please provide your bank details below"
        fill_in I18n.t('views.questions.bank_details.bank_name'), with: "Bank of Two Melons"
        choose I18n.t('views.questions.bank_details.account_type.checking')
        fill_in I18n.t('views.ctc.questions.routing_number.routing_number'), with: "133456789"
        fill_in I18n.t('views.ctc.questions.routing_number.routing_number_confirmation'), with: "133456789"
        click_on I18n.t("general.save")
        expect(page).to have_selector(".text--error", text: I18n.t('validators.routing_number'))
        fill_in I18n.t('views.questions.bank_details.bank_name'), with: "Bank of Two Melons"
        choose I18n.t('views.questions.bank_details.account_type.checking')
        check I18n.t('views.ctc.questions.direct_deposit.my_bank_account.label')

        fill_in I18n.t('views.ctc.questions.routing_number.routing_number'), with: "123456789"
        fill_in I18n.t('views.ctc.questions.routing_number.routing_number_confirmation'), with: "123456789"
        fill_in I18n.t('views.ctc.questions.account_number.account_number'), with: "123456789"
        fill_in I18n.t('views.ctc.questions.account_number.account_number_confirmation'), with: "123456789"
        click_on I18n.t("general.save")

        within ".bank-account-info" do
          expect(page).to have_text "Bank of Two Melons"
          expect(page).to have_text "Type: Checking"
          expect(page).to have_text "Routing number: 123456789"
          expect(page).to have_text "Account number: ●●●●●6789"
        end

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

        notes = SystemNote::CtcPortalUpdate.order(:id)

        expect(changes_table_contents(".changes-note-#{notes[0].id}")).to match({
          "has_primary_ip_pin" => ["unfilled", "no"],
          "primary_first_name" => ["Cher", "Mangonada"],
        })

        expect(changes_table_contents(".changes-note-#{notes[1].id}")).to match({
          "street_address" => ["972 Mission St", "123 Sandwich Lane"],
        })

        expect(changes_table_contents(".changes-note-#{notes[2].id}")).to match({
          "spouse_first_name" => ["Eva", "Pomelostore"],
          "has_spouse_ip_pin" => ["unfilled", "no"],
          "spouse_tin_type" => ["nil", "ssn"],
        })

        expect(changes_table_contents(".changes-note-#{notes[3].id}")).to match({
          "first_name" => ["Kara", "Papaya"],
          "has_ip_pin" => ["unfilled", "no"],
        })

        expect(changes_table_contents(".changes-note-#{notes[4].id}")).to match({
          "bank_name" => ["[REDACTED]", "[REDACTED]"],
          "account_number" => ["[REDACTED]", "[REDACTED]"],
        })

        expect(page).to have_content("Client removed Dependent ##{dependent_to_delete.id}")
        expect(page).to have_content("Client initiated resubmission of their tax return.")
      end

      context "when the client's original intake wants a refund by check" do
        let!(:intake) do
          create(
            :ctc_intake,
            :with_address,
            :with_contact_info,
            :with_ssns,
            email_address: "mango@example.com",
            email_notification_opt_in: "yes",
            refund_payment_method: "check",
          )
        end

        it "does not allow the client ot resubmit if they change to direct deposit with no bank info" do
          log_in_to_ctc_portal
          click_on I18n.t("views.ctc.portal.home.correct_info")

          click_on I18n.t('views.ctc.portal.edit_info.add_bank_information')
          choose I18n.t("views.ctc.questions.refund_payment.direct_deposit")
          click_on I18n.t('general.continue')

          # Go back to the portal
          click_on I18n.t('general.back')
          click_on I18n.t('general.back')

          # Can't resubmit until you enter direct deposit info
          expect(page).to have_selector("button:disabled", text: I18n.t('views.ctc.portal.edit_info.resubmit'))

          click_on I18n.t('views.ctc.portal.edit_info.add_bank_information')
          choose I18n.t("views.ctc.questions.refund_payment.direct_deposit")
          click_on I18n.t('general.continue')

          fill_in I18n.t('views.questions.bank_details.bank_name'), with: "Bank of Two Melons"
          choose I18n.t('views.questions.bank_details.account_type.checking')
          check I18n.t('views.ctc.questions.direct_deposit.my_bank_account.label')

          fill_in I18n.t('views.ctc.questions.routing_number.routing_number'), with: "123456789"
          fill_in I18n.t('views.ctc.questions.routing_number.routing_number_confirmation'), with: "123456789"
          fill_in I18n.t('views.ctc.questions.account_number.account_number'), with: "123456789"
          fill_in I18n.t('views.ctc.questions.account_number.account_number_confirmation'), with: "123456789"
          click_on I18n.t("general.save")

          click_on I18n.t('views.ctc.portal.edit_info.resubmit')
          expect(page).to have_text I18n.t('views.ctc.portal.home.status.preparing.label')
        end
      end

      scenario "a client can change their refund payment method" do
        log_in_to_ctc_portal

        expect(page).to have_selector("h1", text: I18n.t('views.ctc.portal.home.title'))
        expect(page).to have_text "Rejected"

        click_on I18n.t("views.ctc.portal.home.correct_info")
        expect(page).to have_selector("h1", text: I18n.t('views.ctc.portal.edit_info.title'))

        expect(page).to have_text "Your bank information"

        within ".bank-account-info" do
          click_on I18n.t("general.change")
        end

        expect(page).to have_text I18n.t("views.ctc.questions.refund_payment.title")
        choose I18n.t("views.ctc.questions.refund_payment.check")
        click_on I18n.t('general.continue')

        expect(page).to have_text "Edit your address"
        fill_in I18n.t("views.questions.mailing_address.zip_code"), with: "94117"
        click_on "Save"
        
        within ".address-info" do
          expect(page).to have_text "94117"
        end

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

        notes = SystemNote::CtcPortalUpdate.order(:id)

        expect(changes_table_contents(".changes-note-#{notes[1].id}")).to match({"zip_code" => ["94103", "94117"]})

        expect(changes_table_contents(".changes-note-#{notes[0].id}")).to match({"refund_payment_method" => ["direct_deposit", "check"]})

        expect(page).to have_content("Client initiated resubmission of their tax return.")
      end

      scenario "a client sees and can click on a link to continue their intake" do
        log_in_to_ctc_portal

        expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
        expect(page).to have_text "Rejected"
        expect(page).to have_text "IND-189"
        expect(page).to have_text "'DeviceId' in 'AtSubmissionCreationGrp' in 'FilingSecurityInformation' in the Return Header must have a value."
        # only show the first error to the user so as not to overwhelm them
        expect(page).not_to have_text "IND-190: 'DeviceId' in 'AtSubmissionFilingGrp' in 'FilingSecurityInformation' in the Return Header must have a value."
        expect(page).to have_text "Please send us a message with questions or corrections using the \"Contact Us\" button below."
        click_on "Contact us"
        expect(page).to have_selector "h1", text: I18n.t("views.ctc.portal.messages.new.title")
        fill_in I18n.t("views.ctc.portal.messages.new.body_label"), with: "I have some questions about my tax return."
        click_on "Send message"
        expect(page).to have_text "Message sent! Responses will be sent by email to mango@example.com."
      end
    end

    context "efile submission is status cancelled" do
      before do
        es = create(:efile_submission, :rejected, :with_errors, tax_return: create(:tax_return, client: intake.client, year: 2021))
        es.transition_to!(:cancelled)
      end

      scenario "a client sees information about their cancelled submission" do
        log_in_to_ctc_portal

        expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
        expect(page).to have_text I18n.t("views.ctc.portal.home.status.rejected.label")
        expect(page).to have_text I18n.t("views.ctc.portal.home.status.cancelled.message")
        click_on "Contact us"
        expect(page).to have_selector "h1", text: I18n.t("views.ctc.portal.messages.new.title")
        fill_in I18n.t("views.ctc.portal.messages.new.body_label"), with: "I have some questions about my tax return."
        click_on "Send message"
        expect(page).to have_text "Message sent! Responses will be sent by email to mango@example.com."
      end
    end
  end
end
