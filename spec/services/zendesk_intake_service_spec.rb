require "rails_helper"

describe ZendeskIntakeService do
  let(:fake_eitc_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_uwtsa_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_zendesk_ticket) { double(ZendeskAPI::Ticket, id: 2) }
  let(:fake_zendesk_user) { double(ZendeskAPI::User, id: 1) }
  let(:state) { "ne" }
  let(:intake) { create :intake, state: state }
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

    context "in a state for the UW Tucson zendesk instance" do
      let(:state) { "az" }

      it "returns a client for the UW Tucson zendesk instance" do
        expect(service.client).to eq fake_uwtsa_zendesk_client
        expect(UwtsaZendeskInstance).to have_received(:client)
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

    context "in a state for the EITC Zendesk instance" do
      let(:state) { "co" }

      it "calls create_ticket with the right arguments" do
        result = service.create_intake_ticket
        expect(result).to eq 101
        expect(service).to have_received(:create_ticket).with(
          subject: "Cher Cherimoya",
          requester_id: 987,
          group_id: EitcZendeskInstance::ONLINE_INTAKE_THC_UWBA,
          body: "Body text",
          fields: {
            EitcZendeskInstance::INTAKE_SITE => "online_intake",
            EitcZendeskInstance::INTAKE_STATUS => "1._new_online_submission",
          }
        )
      end
    end

    context "in a state for the UWTSA Zendesk instance" do
      let(:state) { "az" }

      it "excludes intake site, and intake status and sends a nil group_id" do
        result = service.create_intake_ticket
        expect(result).to eq 101
        expect(service).to have_received(:create_ticket).with(
          subject: "Cher Cherimoya",
          requester_id: 987,
          group_id: nil,
          body: "Body text",
          fields: {}
        )
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
  end

  describe "#new_ticket_body" do
    let(:expected_body) do
      <<~BODY
        New Online Intake Started

        Name: Cher Cherimoya
        Phone number: (415) 555-1234
        Email: cash@raining.money
        State (based on mailing address): Nebraska

        This filer has:
            • Verified their identity through ID.me
            • Consented to this VITA pilot
      BODY
    end

    it "adds all relevant details about the user and intake" do
      expect(service.new_ticket_body).to eq expected_body
    end
  end

  describe "#new_ticket_group_id" do
    context "with a Tax Help Colorado state" do
      let(:state) { "ne" }
      it "assigns to the shared Tax Help Colorado / UWBA online intake" do
        expect(service.new_ticket_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_THC_UWBA
      end
    end

    context "with California" do
      let(:state) { "ca" }
      it "assigns to the shared Tax Help Colorado / UWBA online intake" do
        expect(service.new_ticket_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_THC_UWBA
      end
    end

    context "with a fed-only state" do
      let(:state) { "ak" }
      it "assigns to the shared Tax Help Colorado / UWBA online intake" do
        expect(service.new_ticket_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_THC_UWBA
      end
    end

    context "with a GWISR state" do
      let(:state) { "ga" }
      it "assigns to the Goodwill online intake" do
        expect(service.new_ticket_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_GWISR
      end
    end

    context "with any other state" do
      let(:state) { "ny" }
      it "assigns to the UW Tucson intake" do
        expect(service.new_ticket_group_id).to be_nil
      end
    end
  end

  describe "#send_intake_pdf" do
    let(:output) { true }
    let(:fake_file) { instance_double(File) }

    before do
      intake.intake_ticket_id = 34
      allow(service).to receive(:append_file_to_ticket).and_return(output)
      allow(intake).to receive(:pdf).and_return(fake_file)
    end

    it "appends the intake pdf to the ticket" do
      result = service.send_intake_pdf
      expect(result).to eq true
      expect(service).to have_received(:append_file_to_ticket).with(
        ticket_id: 34,
        filename: "CherCherimoya_13614c.pdf",
        file: fake_file,
        comment: "New 13614-C Complete"
      )
    end

    context "when the zendesk api fails" do
      let(:output){ false }

      it "raises an error" do
        expect do
          service.send_intake_pdf
        end.to raise_error(ZendeskIntakeService::CouldNotSendIntakePdfError)
      end
    end
  end
end
