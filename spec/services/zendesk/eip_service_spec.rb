require "rails_helper"

describe Zendesk::EipService do
  let(:intake_ticket_requester_id) { 1 }
  let(:vita_partner) { create :vita_partner }
  let(:intake) do
    create(
      :intake,
      :with_contact_info,
      :eip_only,
      intake_ticket_requester_id: intake_ticket_requester_id,
      vita_partner: vita_partner,
      state_of_residence: "CA",
      sms_notification_opt_in: "yes",
      email_notification_opt_in: "yes",
      requested_docs_token: "3456ABCDEF",
      source: "uw-narnia",
      zip_code: "94110",
    )
  end
  let(:fake_zendesk_ticket) { double(ZendeskAPI::Ticket, id: 2) }
  let(:service) { described_class.new(intake) }

  before do
    allow(service).to receive(:create_ticket).and_return(fake_zendesk_ticket)
    allow(service).to receive(:test_ticket_tags).and_return([])
  end

  describe "#create_eip_ticket" do
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
        result = service.create_eip_ticket
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

        expect(result).to eq(fake_zendesk_ticket)
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
    end
  end
end
