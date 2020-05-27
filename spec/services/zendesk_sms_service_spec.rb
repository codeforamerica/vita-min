require "rails_helper"

describe ZendeskSmsService do
  let(:service) { described_class.new }
  let(:sms_ticket_id) { 1492 }
  let(:phone_number) { "14158161286" }
  let(:sms_message_body) { "body here" }
  let(:fake_dogapi) { instance_double(Dogapi::Client, emit_point: nil) }

  before do
    allow(service).to receive(:append_comment_to_ticket).and_return true

    DatadogApi.configure do |c|
      c.enabled = true
      c.namespace = "test.dogapi"
    end
    allow(Dogapi::Client).to receive(:new).and_return(fake_dogapi)
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

      it "sends a datadog metric" do
        service.handle_inbound_sms(
            phone_number: phone_number,
            sms_ticket_id: sms_ticket_id,
            message_body: sms_message_body
        )

        expect(Dogapi::Client).to have_received(:new).once
        expect(fake_dogapi).to have_received(:emit_point).once.with('test.dogapi.zendesk.sms.inbound.user.not_found', 1, {:tags => ["env:"+Rails.env], :type => "count"})
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

      it "sends a datadog metric" do
        service.handle_inbound_sms(
            phone_number: phone_number,
            sms_ticket_id: sms_ticket_id,
            message_body: sms_message_body
        )

        expect(Dogapi::Client).to have_received(:new).once
        expect(fake_dogapi).to have_received(:emit_point).once.with('test.dogapi.zendesk.sms.inbound.user.tickets.not_found', 1, {:tags => ["env:"+Rails.env], :type => "count"})
      end
    end

    context "when there are users, drop offs and Zendesk tickets associated with this phone number" do
      let(:fake_ticket_1) { double(ZendeskAPI::Ticket, id: 1, group_id: "1001", updated_at: DateTime.new(2020, 4, 15, 6, 1), status: "new") }
      let(:fake_ticket_2) { double(ZendeskAPI::Ticket, id: 2, group_id: "1002", updated_at: DateTime.new(2020, 4, 15, 6, 2), status: "new") }
      let(:fake_ticket_3) { double(ZendeskAPI::Ticket, id: 3, group_id: "1003", updated_at: DateTime.new(2020, 4, 15, 6, 3), status: "new") }
      let(:fake_ticket_4) { double(ZendeskAPI::Ticket, id: 4, group_id: "1004", updated_at: DateTime.new(2020, 4, 15, 6, 4), status: "new") }
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
          New text message from client phone: +14158161286
          View all messages at: https://eitc.zendesk.com/agent/tickets/1492
          Message:

          body here
        BODY

        [1, 2, 3, 4].map do |ticket_id|
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

      it "sends a datadog metric" do
        service.handle_inbound_sms(
            phone_number: phone_number,
            sms_ticket_id: sms_ticket_id,
            message_body: sms_message_body
        )

        expect(Dogapi::Client).to have_received(:new).once
        expect(fake_dogapi).to have_received(:emit_point).once.with('test.dogapi.zendesk.sms.inbound.user.tickets.open.linked', 1, {:tags => ["env:"+Rails.env], :type => "count"})
      end
    end

    context "when at least one of the related tickets has a status of closed" do
      let(:fake_ticket_1) { double(ZendeskAPI::Ticket, id: 1, group_id: "1001", updated_at: DateTime.new(2020, 4, 15, 6, 1), status: "new") }
      let(:fake_ticket_2) { double(ZendeskAPI::Ticket, id: 2, group_id: "1002", updated_at: DateTime.new(2020, 4, 15, 6, 2), status: "closed") }
      let(:fake_ticket_3) { double(ZendeskAPI::Ticket, id: 3, group_id: "1003", updated_at: DateTime.new(2020, 4, 15, 6, 3), status: "new") }
      let(:fake_ticket_4) { double(ZendeskAPI::Ticket, id: 4, group_id: "1004", updated_at: DateTime.new(2020, 4, 15, 6, 4), status: "new") }
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

      it "updates the sms ticket with a comment to link to the other relevant open tickets" do
        service.handle_inbound_sms(
          phone_number: phone_number,
          sms_ticket_id: sms_ticket_id,
          message_body: sms_message_body
        )

        expected_comment_body = <<~BODY
          Linked to related tickets:
          • https://eitc.zendesk.com/agent/tickets/1
          • https://eitc.zendesk.com/agent/tickets/3
          • https://eitc.zendesk.com/agent/tickets/4
        BODY

        expect(service).to have_received(:append_comment_to_ticket).with(
          ticket_id: sms_ticket_id,
          comment: expected_comment_body,
          group_id: "1004",
          fields: {
            EitcZendeskInstance::LINKED_TICKET => "https://eitc.zendesk.com/agent/tickets/1,https://eitc.zendesk.com/agent/tickets/3,https://eitc.zendesk.com/agent/tickets/4"
          },
          )
      end

      it "updates only the open related tickets to link and flag them" do
        service.handle_inbound_sms(
          phone_number: phone_number,
          sms_ticket_id: sms_ticket_id,
          message_body: sms_message_body
        )

        expected_comment_body = <<~BODY
          New text message from client phone: +14158161286
          View all messages at: https://eitc.zendesk.com/agent/tickets/1492
          Message:

          body here
        BODY

        [1, 3, 4].map do |ticket_id|
          expect(service).to have_received(:append_comment_to_ticket).with(
            ticket_id: ticket_id,
            comment: expected_comment_body,
            fields: {
              EitcZendeskInstance::LINKED_TICKET => "https://eitc.zendesk.com/agent/tickets/1492",
              EitcZendeskInstance::NEEDS_RESPONSE => true
            },
            )
        end

        expect(service).not_to have_received(:append_comment_to_ticket).with(
          ticket_id: 2,
          comment: expected_comment_body,
          fields: {
            EitcZendeskInstance::LINKED_TICKET => "https://eitc.zendesk.com/agent/tickets/1492",
            EitcZendeskInstance::NEEDS_RESPONSE => true
          },
          )
      end

      it "sends a datadog metric" do
        service.handle_inbound_sms(
            phone_number: phone_number,
            sms_ticket_id: sms_ticket_id,
            message_body: sms_message_body
        )

        expect(Dogapi::Client).to have_received(:new).once
        expect(fake_dogapi).to have_received(:emit_point).once.with('test.dogapi.zendesk.sms.inbound.user.tickets.open.linked', 1, {:tags => ["env:"+Rails.env], :type => "count"})
      end
    end

    context "when ALL of the related tickets have a status of closed" do
      let(:fake_ticket_1) { double(ZendeskAPI::Ticket, id: 1, group_id: "1001", updated_at: DateTime.new(2020, 4, 15, 6, 1), status: "closed") }
      let(:fake_ticket_2) { double(ZendeskAPI::Ticket, id: 2, group_id: "1002", updated_at: DateTime.new(2020, 4, 15, 6, 2), status: "closed") }
      let(:fake_ticket_3) { double(ZendeskAPI::Ticket, id: 3, group_id: "1003", updated_at: DateTime.new(2020, 4, 15, 6, 3), status: "closed") }
      let(:fake_ticket_4) { double(ZendeskAPI::Ticket, id: 4, group_id: "1004", updated_at: DateTime.new(2020, 4, 15, 6, 4), status: "closed") }
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

      it "leaves an internal note on the sms ticket" do
        service.handle_inbound_sms(
          phone_number: phone_number,
          sms_ticket_id: sms_ticket_id,
          message_body: sms_message_body
        )

        expect(service).to have_received(:append_comment_to_ticket).with(
          ticket_id: sms_ticket_id,
          comment: "This user has no associated open tickets.\ntext_user_has_no_other_open_ticket",
          )
      end

      it "sends a datadog metric" do
        service.handle_inbound_sms(
            phone_number: phone_number,
            sms_ticket_id: sms_ticket_id,
            message_body: sms_message_body
        )

        expect(Dogapi::Client).to have_received(:new).once
        expect(fake_dogapi).to have_received(:emit_point).once.with('test.dogapi.zendesk.sms.inbound.user.tickets.open.not_found', 1, {:tags => ["env:"+Rails.env], :type => "count"})
      end

    end
  end

  after do
    DatadogApi.instance_variable_set("@dogapi_client", nil)
  end
end
