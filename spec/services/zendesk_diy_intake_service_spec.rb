require "rails_helper"

describe ZendeskDiyIntakeService do
  let(:requester_id) { 12341321234 } # zendesk requester ids are big integers
  let(:fake_eitc_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_zendesk_user) { double(ZendeskAPI::User, id: requester_id) }
  let(:diy_intake) do
    create(
      :diy_intake,
      email_address: "doit@your.self",
      preferred_name: "Dotty",
      state_of_residence: "NC",
    )
  end
  let(:service) { described_class.new(diy_intake) }

  before do
    allow(service).to receive(:find_or_create_end_user).and_return requester_id
  end

  describe "#instance" do
    it "always uses the EITC zendesk instance" do
      expect(service.instance).to eq EitcZendeskInstance
    end
  end

  describe "#assign_requester" do
    it "finds or creates the end user based on email" do
      service.assign_requester
      expect(service).to have_received(:find_or_create_end_user).with(
        diy_intake.preferred_name, diy_intake.email_address, nil, exact_match: true
      )
    end

    it "updates diy intake requester id" do
      expect { service.assign_requester }
        .to change { diy_intake.requester_id }.from(nil).to(requester_id)
    end

    context "when unable to create a requester" do
      let(:requester_id) { nil }

      it "raises an error" do
        expect { service.assign_requester }
          .to raise_error(ZendeskServiceHelper::ZendeskServiceError)
      end
    end
  end

  describe "#create_diy_intake_ticket" do
    before do
      diy_intake.requester_id = requester_id
    end

    it "calls create_ticket with the right arguments and saves the ticket_id" do
      expect(service).to receive(:ticket_body).and_return "Body text"
      expect(service).to receive(:create_ticket).with(
        subject: "#{diy_intake.preferred_name} DIY Support",
        requester_id: requester_id,
        group_id: ZendeskDiyIntakeService::DIY_SUPPORT_GROUP_ID,
        external_id: "diy-intake-#{diy_intake.id}",
        ticket_form_id: ZendeskDiyIntakeService::DIY_SUPPORT_TICKET_FORM,
        body: "Body text",
        fields: {
          EitcZendeskInstance::STATE => diy_intake.state_of_residence,
          ZendeskDiyIntakeService::DIY_SUPPORT_UNIQUE_LINK => diy_intake.start_filing_url
        }
      ).and_return(101)
      expect { service.create_diy_intake_ticket }.
        to change { diy_intake.ticket_id }.from(nil).to(101)
    end

    context "when we fail to create a zendesk ticket" do
      it "raises an error" do
        expect(service).to receive(:create_ticket).and_return(nil)
        expect { service.create_diy_intake_ticket }
          .to raise_error(ZendeskServiceHelper::ZendeskServiceError)
      end
    end
  end

  describe "#ticket_body" do
    let(:expected_body) do
      <<~BODY
        New DIY Intake Started

        Preferred name: Dotty
        Email: doit@your.self
        State of residence: North Carolina
        Client has been sent DIY link via email

        send_diy_confirmation
      BODY
    end

    it "adds all relevant details about the user and diy intake" do
      expect(service.ticket_body).to eq expected_body
    end
  end

  describe "#ticket_subject" do
    context "in production" do
      before do
        allow(Rails).to receive(:env).and_return("production".inquiry)
      end

      it "returns the name + DIY Support without test ticket suffix" do
        expect(service.ticket_subject)
          .to eq "#{diy_intake.preferred_name} DIY Support"
      end
    end

    context "in test" do
      before do
        allow(Rails).to receive(:env).and_return("test".inquiry)
      end

      it "returns the name + DIY Support without test ticket suffix" do
        expect(service.ticket_subject)
          .to eq "#{diy_intake.preferred_name} DIY Support"
      end
    end

    context "in demo" do
      before do
        allow(Rails).to receive(:env).and_return("demo".inquiry)
      end

      it "returns the name + DIY Support with test ticket suffix" do
        expect(service.ticket_subject)
          .to eq "#{diy_intake.preferred_name} DIY Support (Test Ticket)"
      end
    end
  end

  describe "#append_resend_confirmation_email_comment" do
    before do
      diy_intake.update(ticket_id: 1234)
      allow(service).to receive(:append_comment_to_ticket)
    end

    it "adds a comment to the exisiting Zendesk ticket" do
      service.append_resend_confirmation_email_comment
      expect(service).to have_received(:append_comment_to_ticket)
                           .with(ticket_id: 1234, comment: service.resend_confirmation_email_comment_body)
    end
  end

  describe "#resend_confirmation_email_comment_body" do
    let(:expected_body) do
      <<~BODY
        DIY Intake Started with Duplicate Email

        Preferred name: Dotty
        Email: doit@your.self
        State of residence: North Carolina
        Client has been re-sent DIY link via email

        resend_diy_confirmation
      BODY
    end

    it "adds all relevant details about the user and diy intake" do
      expect(service.resend_confirmation_email_comment_body).to eq expected_body
    end
  end

end
