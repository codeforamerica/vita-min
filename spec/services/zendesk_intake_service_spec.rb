require "rails_helper"

describe ZendeskIntakeService do
  let(:fake_eitc_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_uwtsa_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_zendesk_ticket) { double(ZendeskAPI::Ticket, id: 2) }
  let(:fake_zendesk_user) { double(ZendeskAPI::User, id: 1) }
  let(:state) { "NE" }
  let(:interview_timing_preference) { "" }
  let(:final_info) { "" }
  let(:source) { "uw-narnia" }
  let(:intake) do
    create :intake,
           state_of_residence: state,
           source: source,
           interview_timing_preference: interview_timing_preference,
           final_info: final_info,
           needs_help_2019: "yes",
           needs_help_2018: "no",
           needs_help_2017: "yes",
           requested_docs_token: "3456ABCDEF",
           requested_docs_token_created_at: 2.minutes.ago,
           email_address: "cash@raining.money",
           phone_number: "14155551234",
           primary_first_name: "Cher",
           primary_last_name: "Cherimoya",
           preferred_name: "Cherry",
           email_notification_opt_in: email_opt_in,
           sms_notification_opt_in: sms_opt_in,
           intake_ticket_id: intake_ticket_id,
           intake_ticket_requester_id: intake_requester_id,
           refund_payment_method: payment_method,
           balance_pay_from_bank: pay_from_bank
  end
  let(:service) { described_class.new(intake) }
  let(:email_opt_in) { "yes" }
  let(:sms_opt_in) { "yes" }
  let(:intake_requester_id) { rand(2**(8 * 7)) }
  let(:intake_ticket_id) { nil }
  let(:payment_method) { "direct_deposit" }
  let(:pay_from_bank) { "yes" }

  before do
    allow(ZendeskAPI::Client).to receive(:new).and_return(fake_zendesk_client)
    allow(ZendeskAPI::Ticket).to receive(:new).and_return(fake_zendesk_ticket)
    allow(ZendeskAPI::Ticket).to receive(:find).and_return(fake_zendesk_ticket)
  end

  describe "#client" do
    before do
      allow(EitcZendeskInstance).to receive(:client).and_return fake_eitc_zendesk_client
      allow(UwtsaZendeskInstance).to receive(:client).and_return fake_uwtsa_zendesk_client
    end

    context "when state is nil" do
      let(:state) { nil }

      it "returns a client for the EITC zendesk instance" do
        expect(service.client).to eq fake_eitc_zendesk_client
        expect(EitcZendeskInstance).to have_received(:client)
      end
    end

    context "in a state for the EITC zendesk instance" do
      let(:state) { "co" }

      it "returns a client for the EITC zendesk instance" do
        expect(service.client).to eq fake_eitc_zendesk_client
        expect(EitcZendeskInstance).to have_received(:client)
      end
    end
  end

  describe "#assign_requester" do
    let(:intake_requester_id) { rand(2**(7 * 8)) }

    before do
      allow(service).to receive(:create_intake_ticket_requester) { nil }
    end

    it "does nothing if requester is already assigned" do
      expect(service.assign_requester).to eq(intake_requester_id)
      expect(service).not_to have_received(:create_intake_ticket_requester)
    end

    context "when behaving" do
      let(:ticket_id) { rand(2**(8 * 7)) } ## bigint?
      let(:intake_requester_id) { nil }

      before do
        allow(service).to receive(:create_intake_ticket_requester) { ticket_id }
      end

      it "updates intake ticket requester id" do
        expect(service.assign_requester).to eq(ticket_id)
        expect(intake.intake_ticket_requester_id).to eq(ticket_id)
      end

    end

    context "when unable to create a requester" do
      before do
        allow(service).to receive(:create_intake_ticket_requester) { nil }
        allow(Raven).to receive(:extra_context)
        allow(Raven).to receive(:capture_message)
      end

      it "notifies sentry" do
        user_attributes = {
          name: intake.preferred_name,
          email: intake.email_address,
          phone: intake.phone_number,
          intake_id: intake.id
        }
        intake.intake_ticket_requester_id = nil
        service.assign_requester

        expect(Raven).to have_received(:extra_context).with(hash_including(:intake_id, :level))
        expect(Raven).to have_received(:capture_message)
                           .with(/ZendeskIntakeTicketJob failed to create a ticket requester/)
      end
    end
  end

  describe "#create_intake_ticket_requester" do
    before do
      allow(service).to receive(:find_or_create_end_user).and_return 1
    end

    context "when the user wants all notifications" do
      let(:email_opt_in) { "yes" }
      let(:sms_opt_in) { "yes" }

      it "returns the end user ID based on all contact info" do
        expect(service.create_intake_ticket_requester).to eq 1
        expect(service).to have_received(:find_or_create_end_user).with(
          "Cherry", "cash@raining.money", "+14155551234", exact_match: true
        )
      end
    end

    context "when the user doesn't want any notifications" do
      let(:email_opt_in) { "no" }
      let(:sms_opt_in) { "no" }

      it "returns the end user ID based on just the name" do
        expect(service.create_intake_ticket_requester).to eq 1
        expect(service).to have_received(:find_or_create_end_user).with(
          "Cherry", nil, nil, exact_match: true
        )
      end
    end
  end

  describe "#create_intake_ticket" do
    before do
      intake.intake_ticket_requester_id = 987
      allow(service).to receive(:create_ticket).and_return(101)
      allow(service).to receive(:new_ticket_body).and_return "Body text"
    end

    context "in a state for the EITC Zendesk instance" do
      let(:state) { "co" }
      let!(:vita_partner) { VitaPartner.find_by(name: "Tax Help Colorado (Piton Foundation)") }
      let(:ticket_status) { intake.current_ticket_status }

      it "calls create_ticket with the right arguments" do
        result = service.create_intake_ticket
        expect(result).to eq 101
        expect(service).to have_received(:create_ticket).with(
          subject: "Cher Cherimoya",
          requester_id: 987,
          group_id: vita_partner.zendesk_group_id,
          external_id: "intake-#{intake.id}",
          body: "Body text",
          fields: {
            EitcZendeskInstance::INTAKE_SITE => "online_intake",
            EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_IN_PROGRESS,
            EitcZendeskInstance::STATE => "co",
            EitcZendeskInstance::FILING_YEARS => ["2019", "2017"],
            EitcZendeskInstance::COMMUNICATION_PREFERENCES => ["sms_opt_in", "email_opt_in"],
            EitcZendeskInstance::DOCUMENT_REQUEST_LINK => "#{File.join(Rails.application.routes.url_helpers.root_url, "")}documents/add/3456ABCDEF",
            EitcZendeskInstance::INTAKE_SOURCE => "uw-narnia",
          }
        )
      end

      it "saves the ticket id to the intake" do
        service.create_intake_ticket
        expect(intake.reload.intake_ticket_id).to eq 101
      end

      it "creates the initial TicketStatus for the intake" do
        service.create_intake_ticket
        expect(ticket_status).to be_present
        expect(ticket_status.intake_status).to eq(EitcZendeskInstance::INTAKE_STATUS_IN_PROGRESS)
        expect(ticket_status.return_status).to eq(EitcZendeskInstance::RETURN_STATUS_UNSTARTED)
        expect(ticket_status.verified_change).to eq(true)
        expect(ticket_status.ticket_id).to eq(101)
      end

      it "sends a mixpanel event" do
        mixpanel_spy = spy(MixpanelService)
        allow(MixpanelService).to receive(:instance).and_return(mixpanel_spy)
        service.create_intake_ticket

        expect(mixpanel_spy).to have_received(:run).with(
          unique_id: intake.visitor_id,
          event_name: "ticket_status_change",
          data: intake.mixpanel_data.merge(ticket_status.mixpanel_data)
        )
      end
    end

    context "in a state for the UWTSA Group" do
      let(:state) { "az" }
      let(:vita_partner) { VitaPartner.find_by(name: "United Way of Tuscon and Southern Arizona") }

      it "excludes intake site, and intake status and sends a nil group_id" do
        result = service.create_intake_ticket
        expect(result).to eq 101
        expect(service).to have_received(:create_ticket).with(
          subject: "Cher Cherimoya",
          requester_id: 987,
          group_id: vita_partner.zendesk_group_id,
          external_id: intake.external_id,
          body: "Body text",
          fields: {
            EitcZendeskInstance::INTAKE_SITE => "online_intake",
            EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_IN_PROGRESS,
            EitcZendeskInstance::STATE => "az",
            EitcZendeskInstance::FILING_YEARS => ["2019", "2017"],
            EitcZendeskInstance::COMMUNICATION_PREFERENCES => ["sms_opt_in", "email_opt_in"],
            EitcZendeskInstance::DOCUMENT_REQUEST_LINK => "#{File.join(Rails.application.routes.url_helpers.root_url, "")}documents/add/3456ABCDEF",
            EitcZendeskInstance::INTAKE_SOURCE => "uw-narnia",
          }
        )
      end
    end

    context "when the user opts out of sms notifications" do
      let(:sms_opt_in) { "no" }
      let(:email_opt_in) { "no" }

      it "does not send the 'sms_opt_in'" do
        result = service.create_intake_ticket
        expect(service)
          .to have_received(:create_ticket)
          .with(include(fields: include(EitcZendeskInstance::COMMUNICATION_PREFERENCES => [])))
      end
    end

    context "when the intake does not have a requester id" do
      before { intake.intake_ticket_requester_id = nil }

      it "raises an error" do
        expect do
          service.create_intake_ticket
        end.to raise_error(ZendeskIntakeService::MissingRequesterIdError)
      end
    end

    context "when we fail to create a zendesk ticket" do
      before do
        allow(service).to receive(:create_ticket).and_raise(ZendeskServiceHelper::ZendeskAPIError.new("Error creating Zendesk Ticket"))
      end

      it "raises an error and does not create an initial TicketStatus" do
        expect do
          service.create_intake_ticket
        end.to raise_error(ZendeskServiceHelper::ZendeskAPIError)
        expect(intake.current_ticket_status).to be_nil
      end
    end
  end

  describe "#new_ticket_body" do
    let(:expected_body) do
      <<~BODY
        New Online Intake Started

        Preferred name: Cherry
        Legal first name: Cher
        Legal last name: Cherimoya
        Phone number: (415) 555-1234
        Email: cash@raining.money
        State of residence: Nebraska
        Client answered questions for the 2019 tax year.

        Prefers notifications by:
            • Text message
            • Email

        This filer has consented to this VITA pilot
      BODY
    end

    it "adds all relevant details about the user and intake" do
      expect(service.new_ticket_body).to eq expected_body
    end

    it "adds extra message when client has already filed" do
      intake.update(already_filed: :yes)
      expect(service.new_ticket_body).to include("Client has already filed for 2019")
    end

    it "adds extra message when client filing for economic impact payment support" do
      intake.update(filing_for_stimulus: :yes)
      expect(service.new_ticket_body).to include("Client is filing for Economic Impact Payment support")
    end

  end

  describe "#new_ticket_subject" do
    context "in production" do
      before do
        allow(Rails).to receive(:env).and_return("production".inquiry)
      end

      it "returns the primary full name" do
        expect(service.new_ticket_subject).to eq "Cher Cherimoya"
      end
    end

    context "in test" do
      before do
        allow(Rails).to receive(:env).and_return("test".inquiry)
      end

      it "returns the primary full name" do
        expect(service.new_ticket_subject).to eq "Cher Cherimoya"
      end
    end

    context "in demo" do
      before do
        allow(Rails).to receive(:env).and_return("demo".inquiry)
      end

      it "returns the primary full name and marks it as a test ticket" do
        expect(service.new_ticket_subject).to eq "Cher Cherimoya (Test Ticket)"
      end
    end
  end

  describe "#contact_preferences" do
    context "with sms and email" do
      let(:email_opt_in) { "yes" }
      let(:sms_opt_in) { "yes" }

      it "shows both" do
        expect(service.contact_preferences).to eq <<~TEXT
          Prefers notifications by:
              • Text message
              • Email
        TEXT
      end
    end

    context "with just sms" do
      let(:email_opt_in) { "no" }
      let(:sms_opt_in) { "yes" }

      it "shows just sms" do
        expect(service.contact_preferences).to eq <<~TEXT
          Prefers notifications by:
              • Text message
        TEXT
      end
    end

    context "with neither sms nor email" do
      let(:email_opt_in) { "no" }
      let(:sms_opt_in) { "no" }

      it "says they what they don't want" do
        expect(service.contact_preferences).to eq <<~TEXT
          Did not want email or text message notifications.
        TEXT
      end
    end
  end

  describe "#send_preliminary_intake_and_consent_pdfs" do
    let(:output) { true }
    let(:fake_intake_pdf) { instance_double(File) }
    let(:fake_consent_pdf) { instance_double(File) }

    before do
      intake.intake_ticket_id = 34
      allow(service).to receive(:append_multiple_files_to_ticket).and_return(output)
      allow(intake).to receive(:pdf).and_return(fake_intake_pdf)
      allow(intake).to receive(:consent_pdf).and_return(fake_consent_pdf)
    end

    it "appends the intake and consent pdfs to the ticket" do
      result = service.send_preliminary_intake_and_consent_pdfs

      expected_comment = <<~COMMENT
        Preliminary 13614-C questions answered.

        Primary filer (and spouse, if applicable) consent form attached.
      COMMENT
      expect(result).to eq true
      expect(service).to have_received(:append_multiple_files_to_ticket).with(
        ticket_id: 34,
        file_list: [
          {file: fake_intake_pdf, filename: "13614c_CherCherimoya.pdf"},
          {file: fake_consent_pdf, filename: "Consent_CherCherimoya.pdf"},
        ],
        comment: expected_comment,
        fields: {
          EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS,
          EitcZendeskInstance::DOCUMENT_REQUEST_LINK => "#{File.join(Rails.application.routes.url_helpers.root_url, "")}documents/add/3456ABCDEF",
        }
      )
    end

    context "for UWTSA instance" do
      it "appends the intake pdf to the ticket" do
        intake.zendesk_instance_domain = UwtsaZendeskInstance::DOMAIN

        result = service.send_preliminary_intake_and_consent_pdfs

        expected_comment = <<~COMMENT
          Preliminary 13614-C questions answered.

          Primary filer (and spouse, if applicable) consent form attached.
        COMMENT
        expect(result).to eq true
        expect(service).to have_received(:append_multiple_files_to_ticket).with(
          ticket_id: 34,
          file_list: [
            {file: fake_intake_pdf, filename: "13614c_CherCherimoya.pdf"},
            {file: fake_consent_pdf, filename: "Consent_CherCherimoya.pdf"},
          ],
          comment: expected_comment,
          fields: {
            UwtsaZendeskInstance::INTAKE_STATUS => UwtsaZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS,
            UwtsaZendeskInstance::DOCUMENT_REQUEST_LINK => "#{File.join(Rails.application.routes.url_helpers.root_url, "")}documents/add/3456ABCDEF",
          }
        )
      end
    end

    context "when the zendesk api fails" do
      let(:output){ false }

      it "raises an error" do
        expect do
          service.send_preliminary_intake_and_consent_pdfs
        end.to raise_error(ZendeskIntakeService::CouldNotSendIntakePdfError)
      end
    end
  end

  describe "#send_all_docs" do
    let(:output) { true }
    let!(:documents) do
      [
        create(:document, :with_upload, intake: intake, document_type: "W-2"),
        create(:document, :with_upload, intake: intake, document_type: "1099-MISC"),
      ]
    end

    before do
      intake.intake_ticket_id = 34
      allow(service).to receive(:append_multiple_files_to_ticket).and_return(output)
    end

    it "appends each document to the ticket" do
      result = service.send_all_docs

      expect(result).to eq true

      expect(service).to have_received(:append_multiple_files_to_ticket).with(
        ticket_id: 34,
        file_list: [
          { filename: documents[0].upload.filename, file: instance_of(Tempfile) },
          { filename: documents[1].upload.filename, file: instance_of(Tempfile) },
        ],
        comment: <<~DOCS
          Documents:
          * #{documents[0].upload.filename} (#{documents[0].document_type})
          * #{documents[1].upload.filename} (#{documents[1].document_type})
        DOCS
      )
    end

    context "when the zendesk api fails" do
      let(:output){ false }

      it "raises an error" do
        expect do
          service.send_all_docs
        end.to raise_error(ZendeskIntakeService::CouldNotSendDocumentError)
      end
    end
  end

  describe "#send_final_intake_pdf" do
    let(:output) { true }
    let(:fake_file) { instance_double(File) }
    let(:interview_timing_preference) { "Monday evenings and Wednesday mornings" }
    let(:final_info) { "I want my money" }

    before do
      intake.intake_ticket_id = 34
      allow(service).to receive(:append_file_to_ticket).and_return(output)
      allow(intake).to receive(:pdf).and_return(fake_file)
    end

    it "appends the intake pdf to the ticket with updated status and interview preferences" do
      result = service.send_final_intake_pdf
      expect(result).to eq true
      comment_body = <<~BODY
        Online intake form submitted and ready for review. The taxpayer was notified that their information has been submitted. (automated_notification_submit_confirmation)

        Client's provided interview preferences: Monday evenings and Wednesday mornings

        Additional information from Client: I want my money
      BODY
      expect(service).to have_received(:append_file_to_ticket).with(
        ticket_id: 34,
        filename: "Final13614c_CherCherimoya.pdf",
        file: fake_file,
        comment: comment_body,
        fields: {
          EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_READY_FOR_REVIEW,
          EitcZendeskInstance::DOCUMENT_REQUEST_LINK => "#{File.join(Rails.application.routes.url_helpers.root_url, "")}documents/add/3456ABCDEF",
        }
      )
    end

    context "with UWTSA ZD instance" do
      it "appends the intake pdf to the ticket with updated status and interview preferences" do
        intake.zendesk_instance_domain = UwtsaZendeskInstance::DOMAIN

        result = service.send_final_intake_pdf
        expect(result).to eq true
        comment_body = <<~BODY
          Online intake form submitted and ready for review. The taxpayer was notified that their information has been submitted. (automated_notification_submit_confirmation)

          Client's provided interview preferences: Monday evenings and Wednesday mornings

          Additional information from Client: I want my money
        BODY
        expect(service).to have_received(:append_file_to_ticket).with(
          ticket_id: 34,
          filename: "Final13614c_CherCherimoya.pdf",
          file: fake_file,
          comment: comment_body,
          fields: {
              UwtsaZendeskInstance::INTAKE_STATUS => UwtsaZendeskInstance::INTAKE_STATUS_READY_FOR_REVIEW,
              UwtsaZendeskInstance::DOCUMENT_REQUEST_LINK => "#{File.join(Rails.application.routes.url_helpers.root_url, "")}documents/add/3456ABCDEF",
          }
        )
      end
    end

    context "when the zendesk api fails" do
      let(:output){ false }

      it "raises an error" do
        expect do
          service.send_final_intake_pdf
        end.to raise_error(ZendeskIntakeService::CouldNotSendCompletedIntakePdfError)
      end
    end
  end

  describe "#send_intake_pdf_with_spouse" do
    let(:output) { true }
    let(:fake_file) { instance_double(File) }
    let(:intake_ticket_id) { 34 }

    before do
      allow(service).to receive(:append_file_to_ticket).and_return(output)
      allow(intake).to receive(:pdf).and_return(fake_file)
    end

    it "appends the intake pdf to the ticket with comment indicating spouse presence" do
      result = service.send_intake_pdf_with_spouse

      expect(result).to eq true
      comment_body = <<~BODY
        Updated 13614-c from online intake - added spouse signature and contact
      BODY
      expect(service).to have_received(:append_file_to_ticket).with(
        ticket_id: 34,
        filename: "13614c_CherCherimoya.pdf",
        file: fake_file,
        comment: comment_body,
      )
    end

    context "when the zendesk api fails" do
      let(:output){ false }

      it "raises an error" do
        expect do
          service.send_intake_pdf_with_spouse
        end.to raise_error(ZendeskIntakeService::CouldNotSendCompletedIntakePdfError)
      end
    end
  end

  describe "#send_consent_pdf_with_spouse" do
    let(:output) { true }
    let(:fake_consent_pdf) { instance_double(File) }
    let(:intake_ticket_id) { rand(2**(8 * 7)) }

    before do
      allow(service).to receive(:append_file_to_ticket).and_return(output)
      allow(intake).to receive(:consent_pdf).and_return(fake_consent_pdf)
    end

    it "appends the intake pdf to the ticket with updated status and interview preferences" do
      result = service.send_consent_pdf_with_spouse
      expect(result).to eq true
      expect(service).to have_received(:append_file_to_ticket).with(
        ticket_id: intake.intake_ticket_id,
        filename: "Consent_CherCherimoya.pdf",
        file: fake_consent_pdf,
        comment: "Updated signed consent form with spouse signature\n",
      )
    end

    context "when the zendesk api fails" do
      let(:output){ false }

      it "raises an error" do
        expect do
          service.send_consent_pdf_with_spouse
        end.to raise_error(ZendeskIntakeService::CouldNotSendConsentPdfError)
      end
    end

  end

  describe "#send_bank_details_png" do
    let(:output) { true }
    let(:fake_bank_details_png) { instance_double(File) }

    before do
      intake.intake_ticket_id = 34
      allow(service).to receive(:append_file_to_ticket).and_return(output)
      allow(intake).to receive(:bank_details_png).and_return(fake_bank_details_png)
    end

    context "when the intake includes bank details" do
      it "attaches the bank details png as a comment on the ticket" do
        result = service.send_bank_details_png

        expect(result).to eq true
        comment_body = <<~BODY
          Bank account information for direct deposit and/or payment
        BODY
        expect(service).to have_received(:append_file_to_ticket).with(
          ticket_id: 34,
          filename: "Bank_details_CherCherimoya.png",
          file: fake_bank_details_png,
          comment: comment_body,
        )
      end
    end

    context "when the intake does NOT include bank details" do
      let(:payment_method) { "check" }
      let(:pay_from_bank) { "no"}

      it "does not attach a comment to the ticket and returns true" do
        result = service.send_bank_details_png

        expect(service).not_to have_received(:append_file_to_ticket)
        expect(result).to eq true
      end
    end

    context "when the zendesk api fails" do
      let(:output){ false }

      it "raises an error" do
        expect do
          service.send_bank_details_png
        end.to raise_error(ZendeskIntakeService::CouldNotSendBankDetailsError)
      end
    end
  end
end
