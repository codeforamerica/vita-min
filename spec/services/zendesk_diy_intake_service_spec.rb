require "rails_helper"

describe ZendeskDiyIntakeService do
  let(:requester_id) { 12341321234 } # zendesk requester ids are big integers
  let(:fake_eitc_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_zendesk_user) { double(ZendeskAPI::User, id: requester_id) }
  let(:preferred_name) { "Dotty" }
  let(:state_of_residence) { "NC" }
  let(:email_address) { "doit@your.self" }
  let(:diy_intake) do
    create(
      :diy_intake,
      email_address: email_address,
      preferred_name: preferred_name,
      state_of_residence: state_of_residence,
      locale: :en
    )
  end
  let(:service) { described_class.new(diy_intake) }

  before do
    allow(service).to receive(:create_or_update_zendesk_user).and_return requester_id
    allow(service).to receive(:test_ticket_tags).and_return([])
  end

  describe "#instance" do
    it "always uses the EITC zendesk instance" do
      expect(service.instance).to eq EitcZendeskInstance
    end
  end

  describe "#assign_requester" do
    it "finds or creates the end user based on email" do
      service.assign_requester
      expect(service).to have_received(:create_or_update_zendesk_user).with(
        name: diy_intake.preferred_name, email: diy_intake.email_address,
      )
    end

    it "updates diy intake requester id" do
      expect { service.assign_requester }
        .to change { diy_intake.requester_id }.from(nil).to(requester_id)
    end
  end

  describe "#create_diy_intake_ticket" do
    let(:fake_zendesk_ticket) { double(ZendeskAPI::Ticket, id: 101, errors: nil) }

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
        ticket_form_id: ZendeskDiyIntakeService::DIY_TICKET_FORM,
        body: "Body text",
        fields: {
          EitcZendeskInstance::STATE => "NC",
          EitcZendeskInstance::INTAKE_LANGUAGE => :en,
          ZendeskDiyIntakeService::DIY_SUPPORT_UNIQUE_LINK => "http://test.host/en/diy/#{diy_intake.token}"
        },
        tags: [],
      ).and_return(fake_zendesk_ticket)
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
    it "adds all relevant details about the user and diy intake" do
      body = service.ticket_body
      expect(body).to include "New DIY Intake Started"
      expect(body).to include "Preferred name: #{preferred_name}"
      expect(body).to include "Email: #{email_address}"
      expect(body).to include "State of residence: North Carolina"
      expect(body).to include "Client has been sent DIY link via email"
      expect(body).to include "send_diy_confirmation"
    end

    context "with corresponding full service tickets" do
      let(:intake_ticket_map) do
        { 99998 => double(ZendeskAPI::Ticket, id: "99998"),
          99997 => double(ZendeskAPI::Ticket, id: "99997") }
      end
      let!(:related_intakes) do
        intake_ticket_map.map do |ticket_id, _|
          create(
            :intake,
            email_address: email_address,
            intake_ticket_id: ticket_id
          )
        end
      end

      before do
        intake_ticket_map.each do |tid, ticket|
          allow(service).to receive(:get_ticket!).with(tid).and_return(ticket)
        end
      end

      it "adds references to the full service tickets" do
        body = service.ticket_body

        intake_ticket_map.each do |_, ticket|
          expect(body).to include "This client has a GetYourRefund full service ticket: #{service.ticket_url(ticket.id)}"
        end
      end
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

        diy_confirmation_resend
      BODY
    end

    it "adds all relevant details about the user and diy intake" do
      expect(service.resend_confirmation_email_comment_body).to eq expected_body
    end
  end

end
