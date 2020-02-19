require 'rails_helper'

describe ZendeskDropOffService do
  let(:fake_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_zendesk_ticket) { double(ZendeskAPI::Ticket, id: 2) }
  let(:fake_zendesk_user) { double(ZendeskAPI::User, id: 1) }
  let(:comment_uploads) { [] }
  let(:comment_body) do
    <<~BODY
      New Dropoff at Adams City High School

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

  before do
    allow(ZendeskAPI::Client).to receive(:new).and_return(fake_zendesk_client)
    allow(ZendeskAPI::Ticket).to receive(:new).and_return(fake_zendesk_ticket)
    allow(ZendeskAPI::Ticket).to receive(:find).and_return(fake_zendesk_ticket)

    allow(fake_zendesk_client).to receive_message_chain(:users, :search).and_return([])
    allow(fake_zendesk_client).to receive_message_chain(:users, :create).and_return(fake_zendesk_user)

    allow(fake_zendesk_ticket).to receive(:comment=)
    allow(fake_zendesk_ticket).to receive_message_chain(:comment, :uploads).and_return(comment_uploads)
    allow(fake_zendesk_ticket).to receive(:save)
  end

  describe "#create_ticket_and_attach_file" do
    let(:drop_off) { create :full_drop_off, state: "nv" }

    it "creates a new Zendesk ticket with info from the drop_off and attaches documents to ticket" do
      result = ZendeskDropOffService.new(drop_off).create_ticket_and_attach_file

      expect(ZendeskAPI::Ticket).to have_received(:new).with(
        fake_zendesk_client,
        {
          subject: drop_off.name,
          requester_id: fake_zendesk_user.id,
          group_id: EitcZendeskInstance::TAX_HELP_COLORADO,
          comment: {
            body: comment_body,
          },
          fields: [
            {
              EitcZendeskInstance::CERTIFICATION_LEVEL => drop_off.certification_level,
              EitcZendeskInstance::HSA => true,
              EitcZendeskInstance::INTAKE_SITE => "adams_city_high_school",
              EitcZendeskInstance::STATE => "nv",
              EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_COMPLETE,
              EitcZendeskInstance::SIGNATURE_METHOD => drop_off.signature_method,
            }
          ]
        }
      )
      expect(result).to eq 2
      expect(comment_uploads.first[:filename]).to eq "GaryGuava.pdf"
      expect(fake_zendesk_ticket).to have_received(:save)
    end

    context "from Goodwill Industries of the Southern Rivers" do
      let(:drop_off) do
        create(:full_drop_off, organization: "gwisr", state: "ga", intake_site: "GoodwillSR Columbus Intake")
      end
      let(:comment_body) do
        <<~BODY
          New Dropoff at GoodwillSR Columbus Intake
    
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
        ZendeskDropOffService.new(drop_off).create_ticket_and_attach_file
        expect(ZendeskAPI::Ticket).to have_received(:new).with(
          fake_zendesk_client,
          {
            subject: drop_off.name,
            requester_id: fake_zendesk_user.id,
            group_id: EitcZendeskInstance::GOODWILL_SOUTHERN_RIVERS,
            comment: {
              body: comment_body,
            },
            fields: [
              {
                EitcZendeskInstance::CERTIFICATION_LEVEL => drop_off.certification_level,
                EitcZendeskInstance::HSA => true,
                EitcZendeskInstance::INTAKE_SITE => "goodwillsr_columbus_intake",
                EitcZendeskInstance::STATE => "ga",
                EitcZendeskInstance::INTAKE_STATUS => "3._ready_for_prep",
                EitcZendeskInstance::SIGNATURE_METHOD => drop_off.signature_method,
              }
            ]
          }
        )
      end
    end
  end

  describe "#append_to_existing_ticket" do
    let(:drop_off) { create :full_drop_off, zendesk_ticket_id: "48", state: "nv" }

    before do
      allow(fake_zendesk_ticket).to receive(:save).and_return(true)
    end

    it "appends a comment and document to the ticket" do
      result = ZendeskDropOffService.new(drop_off).append_to_existing_ticket

      expect(ZendeskAPI::Ticket).to have_received(:find).with(fake_zendesk_client, id: "48")
      expect(fake_zendesk_ticket).to have_received(:comment=).with({body: comment_body})
      expect(comment_uploads.first[:filename]).to eq "GaryGuava.pdf"
      expect(fake_zendesk_ticket).to have_received(:save)
      expect(result).to eq true
    end
  end

  describe "#file_upload_name" do
    let(:document_bundle) do
      Rack::Test::UploadedFile.new("spec/fixtures/attachments/picture_id.jpg", "image/jpeg")
    end
    let(:drop_off) { create :intake_site_drop_off, name: "Kendra Kiwi", document_bundle: document_bundle }

    it "returns the drop off name and correct file extension" do
      result = ZendeskDropOffService.new(drop_off).file_upload_name

      expect(result).to eq "KendraKiwi.jpg"
    end
  end

  describe "#find_end_user" do
    let(:search_results) { [fake_zendesk_user] }
    let(:service) { ZendeskDropOffService.new(nil) }

    before do
      allow(service).to receive(:search_zendesk_users).with(kind_of(String)).and_return(search_results)
    end

    context "when email is present" do
      it "searches by email" do
        service.find_end_user(nil, "test@example.com", nil)
        expect(service).to have_received(:search_zendesk_users).with("email:test@example.com")
      end

      context "when there are no email matches" do
        before do
          allow(service).to receive(:search_zendesk_users).with("email:test@example.com").and_return([])
          allow(service).to receive(:search_zendesk_users).with("name:\"Barry Banana\" phone:14155551234").and_return(search_results)
        end

        it "searches by name and phone" do
          result = service.find_end_user("Barry Banana", "test@example.com", "14155551234")
          expect(service).to have_received(:search_zendesk_users).with("email:test@example.com")
          expect(service).to have_received(:search_zendesk_users).with("name:\"Barry Banana\" phone:14155551234")
          expect(result).to eq(1)
        end
      end
    end

    context "when only phone and name are present" do
      it "searches with phone and name" do
        service.find_end_user("Gary Guava", nil, "14155555555")
        expect(service).to have_received(:search_zendesk_users).with("name:\"Gary Guava\" phone:14155555555")
      end
    end

    context "when only name is present" do
      it "searches with only name" do
        service.find_end_user("Gary Guava", nil, nil)
        expect(service).to have_received(:search_zendesk_users).with("name:\"Gary Guava\"")
      end
    end

    context "when there are no search results" do
      let(:search_results) { [] }
      it "returns nil" do
        result = service.find_end_user("Gary Guava", "test@example.com", "14155555555")
        expect(result).to eq nil
      end
    end
  end

  describe "#comment_body" do
    let(:drop_off) { create :full_drop_off }

    it "puts all the details in the comment body" do
      result = ZendeskDropOffService.new(drop_off).comment_body

      expected_body = <<~BODY
        New Dropoff at Adams City High School

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
