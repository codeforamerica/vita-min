require 'rails_helper'

describe ZendeskDropOffService do
  let(:fake_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_zendesk_ticket) { double(ZendeskAPI::Ticket, id: 2, errors: nil) }
  let(:fake_zendesk_user) { double(ZendeskAPI::User, id: 1) }
  let(:fake_zendesk_search_results) { double("Collection", to_a!: [])}
  let(:comment_uploads) { [] }
  let(:comment_body) do
    <<~BODY
      New Dropoff at Adams City High School

      To view the client's documents, see the "Link to Client's Documents" in Zendesk.

      Certification Level: Basic and HSA
      Name: Gary Guava
      Phone number: (415) 816-1286
      Email: gguava@example.com
      Signature method: E-Signature
      Pickup Date: 4/10/2020
      State (for state tax return): Nevada
      Additional info: Gary is missing a document
    BODY
  end
  let(:service) { described_class.new(drop_off) }

  before do
    allow(ZendeskAPI::Client).to receive(:new).and_return(fake_zendesk_client)
    allow(ZendeskAPI::Ticket).to receive(:new).and_return(fake_zendesk_ticket)
    allow(ZendeskAPI::Ticket).to receive(:find).and_return(fake_zendesk_ticket)

    allow(fake_zendesk_ticket).to receive(:comment=)
    allow(fake_zendesk_ticket).to receive_message_chain(:comment, :uploads).and_return(comment_uploads)
    allow(fake_zendesk_ticket).to receive(:save!).and_return(true)
    allow(fake_zendesk_ticket).to receive(:fields=)
  end

  describe "#create_ticket" do
    let(:drop_off) { create :full_drop_off, state: "NV" }

    before do
      allow(service).to receive(:assign_requester) { fake_zendesk_user.id }
    end

    context "successfully creating ticket" do
      it "creates a new Zendesk ticket with info from the drop_off and updates document link field" do
        result = service.create_ticket

        expect(ZendeskAPI::Ticket).to have_received(:new).with(
          fake_zendesk_client,
          {
            subject: drop_off.name,
            requester_id: fake_zendesk_user.id,
            group_id: EitcZendeskInstance::TAX_HELP_COLORADO,
            external_id: "drop-off-#{drop_off.id}",
            comment: {
              body: comment_body,
              public: true,
            },
            fields: [
              {
                EitcZendeskInstance::CERTIFICATION_LEVEL => drop_off.certification_level,
                EitcZendeskInstance::HSA => true,
                EitcZendeskInstance::INTAKE_SITE => "adams_city_high_school",
                EitcZendeskInstance::COMMUNICATION_PREFERENCES => ["email_opt_in", "sms_opt_in"],
                EitcZendeskInstance::STATE => "NV",
                EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_COMPLETE,
                EitcZendeskInstance::SIGNATURE_METHOD => drop_off.signature_method,
              }
            ]
          }
        )
        expect(result).to eq 2

        expect(fake_zendesk_ticket).to have_received(:save!)
      end

      context "from Goodwill Industries of the Southern Rivers" do
        let(:drop_off) do
          create(:full_drop_off, organization: "gwisr", state: "GA", intake_site: "GoodwillSR Columbus Intake")
        end
        let(:comment_body) do
          <<~BODY
            New Dropoff at GoodwillSR Columbus Intake

            To view the client's documents, see the "Link to Client's Documents" in Zendesk.

            Certification Level: Basic and HSA
            Name: Gary Guava
            Phone number: (415) 816-1286
            Email: gguava@example.com
            Signature method: E-Signature
            Pickup Date: 4/10/2020
            State (for state tax return): Georgia
            Additional info: Gary is missing a document
          BODY
        end

        it "assigns the Zendesk ticket to the correct group" do
          service.create_ticket
          expect(ZendeskAPI::Ticket).to have_received(:new).with(
            fake_zendesk_client,
            {
              subject: drop_off.name,
              requester_id: fake_zendesk_user.id,
              group_id: EitcZendeskInstance::GOODWILL_SOUTHERN_RIVERS,
              external_id: "drop-off-#{drop_off.id}",
              comment: {
                body: comment_body,
                public: true,
              },
              fields: [
                {
                  EitcZendeskInstance::CERTIFICATION_LEVEL => drop_off.certification_level,
                  EitcZendeskInstance::HSA => true,
                  EitcZendeskInstance::INTAKE_SITE => "goodwillsr_columbus_intake",
                  EitcZendeskInstance::COMMUNICATION_PREFERENCES => ["email_opt_in", "sms_opt_in"],
                  EitcZendeskInstance::STATE => "GA",
                  EitcZendeskInstance::INTAKE_STATUS => "3._ready_for_prep",
                  EitcZendeskInstance::SIGNATURE_METHOD => drop_off.signature_method,
                }
              ]
            }
          )
        end
      end
      
      context "without a phone number" do
        let(:drop_off) { create(:full_drop_off, phone_number: nil) }
        
        it "only sets the email_opt_in tag" do
          service.create_ticket

          expect(ZendeskAPI::Ticket).to have_received(:new).with(
            fake_zendesk_client,
            hash_including(
              fields: [
                hash_including(EitcZendeskInstance::COMMUNICATION_PREFERENCES => ["email_opt_in"])
              ]
            )
          )
        end
      end
      
      context "without an email address" do
        let(:drop_off) { create(:full_drop_off, email: nil) }

        it "only sets the sms_opt_in tag" do
          service.create_ticket

          expect(ZendeskAPI::Ticket).to have_received(:new).with(
            fake_zendesk_client,
            hash_including(
              fields: [
                hash_including(EitcZendeskInstance::COMMUNICATION_PREFERENCES => ["sms_opt_in"])
              ]
            )
          )
        end
      end
    end
  end

  describe "#append_to_existing_ticket" do
    let(:drop_off) { create :full_drop_off, zendesk_ticket_id: "48", state: "NV" }

    before do
      allow(fake_zendesk_ticket).to receive(:save!).and_return(true)
    end

    it "appends a comment and document to the ticket" do
      result = ZendeskDropOffService.new(drop_off).append_to_existing_ticket

      expect(ZendeskAPI::Ticket).to have_received(:find).with(fake_zendesk_client, id: "48")
      expect(fake_zendesk_ticket).to have_received(:comment=).with({body: comment_body, public: false})
      expect(fake_zendesk_ticket).to have_received(:save!)
      expect(result).to eq true
    end
  end

  describe "#assign_requester" do
    let(:drop_off) { create :full_drop_off, state: "NV" }

    before do
      allow(service).to receive(:create_or_update_zendesk_user) { fake_zendesk_user.id }
    end

    it "returns zendesk user ID" do
      expect(service.assign_requester).to eq fake_zendesk_user.id
    end

    context "phone is nil" do
      let(:drop_off) { create :intake_site_drop_off, email: "gguava@example.com", state: "NV" }

      it "sends name and email" do
        service.assign_requester

        expect(service).to have_received(:create_or_update_zendesk_user).with({
          name: drop_off.name,
          email: drop_off.email
        })
      end
    end

    context "email is nil" do
      let(:drop_off) { create :intake_site_drop_off, phone_number: "4158161286", state: "NV" }

      it "sends name and standardized phone" do
        service.assign_requester

        expect(service).to have_received(:create_or_update_zendesk_user).with({
          name: drop_off.name,
          phone: "+14158161286"
        })
      end
    end

    context "has both email and phone" do
      let(:drop_off) { create :full_drop_off, state: "NV" }

      it "sends name and standardized phone" do
        service.assign_requester

        expect(service).to have_received(:create_or_update_zendesk_user).with({
          name: drop_off.name,
          phone: "+14158161286",
          email: drop_off.email,
        })
      end
    end
  end

  describe "#comment_body" do
    let(:drop_off) { create :full_drop_off }

    it "puts all the details in the comment body" do
      result = ZendeskDropOffService.new(drop_off).comment_body

      expected_body = <<~BODY
        New Dropoff at Adams City High School

        To view the client's documents, see the "Link to Client's Documents" in Zendesk.

        Certification Level: Basic and HSA
        Name: Gary Guava
        Phone number: (415) 816-1286
        Email: gguava@example.com
        Signature method: E-Signature
        Pickup Date: 4/10/2020
        State (for state tax return): Colorado
        Additional info: Gary is missing a document
      BODY
      expect(result).to eq expected_body
    end

    context "without pickup date" do
      it "excludes pickup date line" do
        drop_off.pickup_date = nil
        result = ZendeskDropOffService.new(drop_off).comment_body

        expected_body = <<~BODY
          New Dropoff at Adams City High School

          To view the client's documents, see the "Link to Client's Documents" in Zendesk.

          Certification Level: Basic and HSA
          Name: Gary Guava
          Phone number: (415) 816-1286
          Email: gguava@example.com
          Signature method: E-Signature
          State (for state tax return): Colorado
          Additional info: Gary is missing a document
        BODY
        expect(result).to eq expected_body
      end
    end
  end
end
