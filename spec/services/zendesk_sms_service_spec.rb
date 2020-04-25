require "rails_helper"

describe ZendeskSmsService do
  let(:service) { described_class.new }
  let(:sms_ticket_id) { 1492 }
  let(:phone_number) { "14158161286" }
  let(:sms_message_body) { "body here" }

  before do
    allow(service).to receive(:append_comment_to_ticket).and_return true
  end

  describe "#handle_inbound_sms" do
    context "when there is no record with this phone number" do
      it "leaves an internal note on the sms ticket" do
        service.handle_inbound_sms(
          phone_number: phone_number,
          sms_ticket_id: sms_ticket_id,
          message_body: sms_message_body
        )

        expect(service).to have_received(:append_comment_to_ticket).with(
          ticket_id: sms_ticket_id,
          comment: "This user could not be found.\ntext_user_not_found",
        )
      end
    end

    context "when we found the phone number in our records but don't have any zendesk ticket ids" do
      let!(:drop_off) do
        create(:intake_site_drop_off, phone_number: phone_number, zendesk_ticket_id: nil)
      end
      let(:intake) { create :intake, intake_ticket_id: nil, phone_number: phone_number }

      it "leaves an internal note on the sms ticket" do
        service.handle_inbound_sms(
          phone_number: phone_number,
          sms_ticket_id: sms_ticket_id,
          message_body: sms_message_body
        )

        expect(service).to have_received(:append_comment_to_ticket).with(
          ticket_id: sms_ticket_id,
          comment: "This user has no associated tickets.\ntext_user_has_no_other_ticket",
          )
      end
    end

    context "when there are users, drop offs and Zendesk tickets associated with this phone number" do
      let(:fake_ticket_1) { double(ZendeskAPI::Ticket, id: 1, group_id: "1001", updated_at: DateTime.new(2020, 4, 15, 6, 1)) }
      let(:fake_ticket_2) { double(ZendeskAPI::Ticket, id: 2, group_id: "1002", updated_at: DateTime.new(2020, 4, 15, 6, 2)) }
      let(:fake_ticket_3) { double(ZendeskAPI::Ticket, id: 3, group_id: "1003", updated_at: DateTime.new(2020, 4, 15, 6, 3)) }
      let(:fake_ticket_4) { double(ZendeskAPI::Ticket, id: 4, group_id: "1004", updated_at: DateTime.new(2020, 4, 15, 6, 4)) }
      let!(:drop_offs) do
        [
          create(:intake_site_drop_off, phone_number: phone_number, zendesk_ticket_id: "1"),
          create(:intake_site_drop_off, phone_number: phone_number, zendesk_ticket_id: "2")
        ]
      end
      let!(:first_intake) { create :intake, intake_ticket_id: 3, phone_number: phone_number }
      let!(:second_intake) { create :intake, intake_ticket_id: 4, phone_number: phone_number }

      before do
        allow(service).to receive(:assign_ticket_to_group).and_return true
        allow(service).to receive(:get_ticket).with(ticket_id: "1").and_return fake_ticket_1
        allow(service).to receive(:get_ticket).with(ticket_id: "2").and_return fake_ticket_2
        allow(service).to receive(:get_ticket).with(ticket_id: "3").and_return fake_ticket_3
        allow(service).to receive(:get_ticket).with(ticket_id: "4").and_return fake_ticket_4
      end

      it "updates the sms ticket with a comment to link to the other relevant tickets" do
        service.handle_inbound_sms(
          phone_number: phone_number,
          sms_ticket_id: sms_ticket_id,
          message_body: sms_message_body
        )

        expected_comment_body = <<~BODY
          Linked to related tickets:
          • https://eitc.zendesk.com/agent/tickets/1
          • https://eitc.zendesk.com/agent/tickets/2
          • https://eitc.zendesk.com/agent/tickets/3
          • https://eitc.zendesk.com/agent/tickets/4
        BODY

        expect(service).to have_received(:append_comment_to_ticket).with(
          ticket_id: sms_ticket_id,
          comment: expected_comment_body,
          group_id: "1004",
          fields: {
            EitcZendeskInstance::LINKED_TICKET => "https://eitc.zendesk.com/agent/tickets/1,https://eitc.zendesk.com/agent/tickets/2,https://eitc.zendesk.com/agent/tickets/3,https://eitc.zendesk.com/agent/tickets/4"
          },
        )
      end

      it "updates each related ticket to link it and flag it" do
        service.handle_inbound_sms(
          phone_number: phone_number,
          sms_ticket_id: sms_ticket_id,
          message_body: sms_message_body
        )

        expected_comment_body = <<~BODY
          New text message from client phone: 14158161286
          To respond to the client via text message, go to this ticket: https://eitc.zendesk.com/agent/tickets/1492

          ---------------------------
          
          Message:

          body here
        BODY

        ["1", "2", "3", "4"].map do |ticket_id|
          expect(service).to have_received(:append_comment_to_ticket).with(
            ticket_id: ticket_id,
            comment: expected_comment_body,
            fields: {
              EitcZendeskInstance::LINKED_TICKET => "https://eitc.zendesk.com/agent/tickets/1492",
              EitcZendeskInstance::NEEDS_RESPONSE => true
            },
          )
        end
      end
    end
  end
end
