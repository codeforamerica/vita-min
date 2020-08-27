require "rails_helper"

describe Zendesk::EipService do
  let(:intake_ticket_requester_id) { 1 }
  let(:intake_ticket_id) { nil }
  let(:vita_partner) { create :vita_partner }
  let(:source) { "uw-narnia" }
  let(:intake) do
    create(
      :intake,
      :with_contact_info,
      :eip_only,
      intake_ticket_requester_id: intake_ticket_requester_id,
      intake_ticket_id: intake_ticket_id,
      vita_partner: vita_partner,
      state_of_residence: "CA",
      sms_notification_opt_in: "yes",
      email_notification_opt_in: "yes",
      requested_docs_token: "3456ABCDEF",
      source: source,
      zip_code: "94110",
    )
  end
  let(:fake_zendesk_ticket) { double(ZendeskAPI::Ticket, id: 2) }
  let(:service) { described_class.new(intake) }

  before do
    allow(service).to receive(:append_comment_to_ticket)
    allow(service).to receive(:create_ticket).and_return(fake_zendesk_ticket)
    allow(service).to receive(:test_ticket_tags).and_return([])
    allow(DatadogApi).to receive(:increment)
  end

  describe "#create_eip_ticket" do
    context "with a pre-existing zendesk ticket" do
      let(:intake_ticket_id) { 2 }

      it "does not create zendesk ticket or leave any comments" do
        service.create_eip_ticket
        expect(service).not_to have_received(:create_ticket)
        expect(service).not_to have_received(:append_comment_to_ticket)
        expect(intake.reload.intake_ticket_id).to be(intake_ticket_id)
      end
    end

    context "with other pre-existing intake tickets in Zendesk" do
      context "with a DIY intake" do
        let!(:diy_intake) { create :diy_intake, email_address: intake.email_address }

        it "includes note in comment body that the DIY intake exists too" do
          service.create_eip_ticket
          expect(service).to have_received(:create_ticket).with(
            hash_including(
              body: including("This client has previously requested a DIY link from GetYourRefund.org"),
            )
          )
        end
      end

      context "with a full intake" do
        let!(:full_intake) { create :intake, email_address: intake.email_address, intake_ticket_id: 123 }

        it "includes note in comment body that the full intake exists too" do
          service.create_eip_ticket
          expect(service).to have_received(:create_ticket).with(
            hash_including(
              body: including("This client has a GetYourRefund full intake ticket: #{service.ticket_url(full_intake.intake_ticket_id)}"),
            )
          )
        end
      end
    end

    context "with nil intake_ticket_requester_id" do
      let(:intake_ticket_requester_id) { nil }

      it "crashes with MissingRequesterIdError" do
        expect { service.create_eip_ticket }.to raise_error(Zendesk::EipService::MissingRequesterIdError)
      end
    end

    context "with nil vita_partner" do
      let(:vita_partner) { nil }

      it "crashes with an error" do
        expect { service.create_eip_ticket }.to raise_error("Missing vita_partner")
      end
    end

    context "with intake_ticket_requester_id" do
      it "calls create_ticket with the right arguments" do
        expected_body = <<~BODY
          New EIP only form started

          Preferred name: Cherry
          Legal first name: Cher
          Legal last name: Cherimoya
          Phone number: (415) 555-1212
          Email: cher@example.com
          State of residence: California

          Prefers notifications by:
              • Text message
              • Email

          This filer has consented to this VITA pilot.
        BODY

        expect(TicketStatus.count).to eq(0)
        service.create_eip_ticket
        expect(service).to have_received(:create_ticket).with(
          subject: "Cher Cherimoya EIP",
          body: expected_body,
          requester_id: intake_ticket_requester_id,
          group_id: vita_partner.zendesk_group_id,
          external_id: "intake-#{intake.id}",
          ticket_form_id: EitcZendeskInstance::EIP_TICKET_FORM,
          tags: [],
          fields: {
              EitcZendeskInstance::COMMUNICATION_PREFERENCES => %w[sms_opt_in email_opt_in],
              EitcZendeskInstance::EIP_STATUS => EitcZendeskInstance::EIP_STATUS_STARTED,
              EitcZendeskInstance::DOCUMENT_REQUEST_LINK => "http://test.host/documents/add/3456ABCDEF",
              EitcZendeskInstance::INTAKE_SITE => "eip_only_return",
              EitcZendeskInstance::INTAKE_LANGUAGE => :en,
              EitcZendeskInstance::INTAKE_SOURCE => "uw-narnia",
              EitcZendeskInstance::STATE => "CA",
              EitcZendeskInstance::CLIENT_ZIP_CODE => "94110",
          }
        )
      end

      it "creates a TicketStatus with EIP status started" do
        expect(TicketStatus.count).to eq(0)
        service.create_eip_ticket
        expect(TicketStatus.count).to eq(1)
        expect(TicketStatus.first.eip_status).to eq(EitcZendeskInstance::EIP_STATUS_STARTED)
      end
    end

    context "with an associated stimulus triage" do
      before { create :stimulus_triage, intake: intake }

      it "adds triaged_from_stimulus tag" do
        service.create_eip_ticket
        expect(service).to have_received(:create_ticket).with hash_including(
          tags: ["triaged_from_stimulus"]
        )
      end
    end

    context "with intake source of 211intake" do
      let(:source) { "211intake" }

      it "adds 211_eip_intake tag" do
        expected_body = <<~BODY
          Client called 211 EIP hotline and a VITA certified 211 specialist talked to the client and completed the intake form

          New EIP only form started

          Preferred name: Cherry
          Legal first name: Cher
          Legal last name: Cherimoya
          Phone number: (415) 555-1212
          Email: cher@example.com
          State of residence: California

          Prefers notifications by:
              • Text message
              • Email

          This filer has consented to this VITA pilot.
        BODY

        service.create_eip_ticket
        expect(service).to have_received(:create_ticket).with(
          hash_including(
            body: expected_body,
            fields: hash_including(
              EitcZendeskInstance::INTAKE_SOURCE => "211intake",
              EitcZendeskInstance::REFERRAL_BY_211 => true
            ),
            tags: ["211_eip_intake"]
          )
        )
      end
    end

    context "when there are tickets for other service options" do
      let!(:diy_intake) { create :diy_intake, email_address: intake.email_address, ticket_id: fake_zendesk_ticket.id + 1 }
      let!(:full_service_intake) { create :intake, email_address: intake.email_address, intake_ticket_id: fake_zendesk_ticket.id + 2 }

      it "appends a comment the other tickets" do
        service.create_eip_ticket
        expect(service).to have_received(:append_comment_to_ticket).with(
          ticket_id: diy_intake.ticket_id,
          comment: "This client has a GetYourRefund EIP ticket: https://eitc.zendesk.com/agent/tickets/2",
          skip_if_closed: true
        )
        expect(service).to have_received(:append_comment_to_ticket).with(
          ticket_id: full_service_intake.intake_ticket_id,
          comment: "This client has a GetYourRefund EIP ticket: https://eitc.zendesk.com/agent/tickets/2",
          skip_if_closed: true
        )
      end
    end
  end

  describe "#send_consent_to_zendesk" do
    let(:intake_ticket_id) { 2 }

    context "when comment has already been appended" do
      before do
        intake.update(intake_pdf_sent_to_zendesk: true)
      end

      it "does not append the comment again" do
        service.send_consent_to_zendesk
        expect(service).not_to have_received(:append_comment_to_ticket)
      end
    end

    context "when comment has not been appended" do
      it "appends a comment and updates the eip return status" do
        service.send_consent_to_zendesk
        expected_comment = <<~COMMENT
          Preliminary 13614-C questions answered.

          See "Link to Client Documents" for 13614-C PDF and consent PDF(s).
        COMMENT
        expect(service).to have_received(:append_comment_to_ticket).with(
          ticket_id: 2,
          comment: expected_comment,
          fields: {
            EitcZendeskInstance::EIP_STATUS => EitcZendeskInstance::EIP_STATUS_ID_UPLOAD,
            EitcZendeskInstance::LINK_TO_CLIENT_DOCUMENTS => "http://test.host/en/zendesk/tickets/2",
          }
        )
        expect(DatadogApi).to have_received(:increment).with(
          "zendesk.ticket.pdfs.intake_and_consent.preliminary.sent"
        )
        expect(intake.reload.intake_pdf_sent_to_zendesk).to eq true
      end
    end
  end

  describe "#send_completed_intake_to_zendesk" do
    let(:intake_ticket_id) { 2 }

    context "has not sent completed intake" do
      before do
        intake.update(
          preferred_interview_language: "es",
          timezone: "America/Chicago",
          final_info: "I moved here from Alaska.",
          interview_timing_preference: "Monday evenings and Wednesday mornings",
        )
      end

      it "adds a comment" do
        service.send_completed_intake_to_zendesk

        expected_comment = <<~COMMENT
          EIP only form submitted. The taxpayer was notified that their information has been submitted.

          Client's detected timezone: Central Time (US & Canada)
          Client's provided interview preferences: Monday evenings and Wednesday mornings
          The client's preferred language for a phone call is Spanish

          Additional information from Client: I moved here from Alaska.

          automated_notification_submit_confirmation
        COMMENT
        expect(service).to have_received(:append_comment_to_ticket).with(
          ticket_id: 2,
          comment: expected_comment,
          fields: {
            EitcZendeskInstance::EIP_STATUS => EitcZendeskInstance::EIP_STATUS_SUBMITTED,
          }
        )
        expect(DatadogApi).to have_received(:increment).with("zendesk.ticket.pdfs.intake.final.sent")
        expect(intake.reload.completed_intake_sent_to_zendesk).to eq true
      end
    end

    context "has sent completed intake" do
      before do
        intake.update(completed_intake_sent_to_zendesk: true)
      end

      it "does nothing" do
        service.send_completed_intake_to_zendesk
        expect(service).not_to have_received(:append_comment_to_ticket)
      end
    end
  end
end
