require "rails_helper"

describe ZendeskIntakeService do
  let(:fake_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_zendesk_ticket) { double(ZendeskAPI::Ticket, id: 2) }
  let(:fake_zendesk_user) { double(ZendeskAPI::User, id: 1) }
  let(:intake) { create :intake }
  let(:service) { described_class.new(intake) }
  let(:email_opt_in) { "yes" }
  let(:sms_opt_in) { "yes" }
  let!(:user) do
    create :user,
           intake: intake,
           first_name: "Cher",
           last_name: "Cherimoya",
           email: "cash@raining.money",
           phone_number: "14155551234",
           email_notification_opt_in: email_opt_in,
           sms_notification_opt_in: sms_opt_in
  end

  before do
    allow(ZendeskAPI::Client).to receive(:new).and_return(fake_zendesk_client)
    allow(ZendeskAPI::Ticket).to receive(:new).and_return(fake_zendesk_ticket)
    allow(ZendeskAPI::Ticket).to receive(:find).and_return(fake_zendesk_ticket)
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
          "Cher Cherimoya", "cash@raining.money", "14155551234", exact_match: true
        )
      end
    end

    context "when the user doesn't want any notifications" do
      let(:email_opt_in) { "no" }
      let(:sms_opt_in) { "no" }

      it "returns the end user ID based on just the name" do
        expect(service.create_intake_ticket_requester).to eq 1
        expect(service).to have_received(:find_or_create_end_user).with(
          "Cher Cherimoya", nil, nil, exact_match: true
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

    it "calls create_ticket with the right arguments" do
      result = service.create_intake_ticket
      expect(result).to eq 101
      expect(service).to have_received(:create_ticket).with(
        subject: "Cher Cherimoya",
        requester_id: 987,
        group_id: ZendeskServiceHelper::ONLINE_INTAKE_THC_UWBA,
        body: "Body text",
        fields: {
          ZendeskServiceHelper::INTAKE_SITE => "online_intake",
          ZendeskServiceHelper::INTAKE_STATUS => "1._new_online_submission",
        }
      )
    end

    context "when the intake does not have a requester id" do
      before { intake.intake_ticket_requester_id = nil }

      it "raises an error" do
        expect do
          service.create_intake_ticket
        end.to raise_error(ZendeskIntakeService::MissingRequesterIdError)
      end
    end
  end
end
