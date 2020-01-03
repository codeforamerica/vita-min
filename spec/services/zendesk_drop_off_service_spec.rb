require 'rails_helper'

describe ZendeskDropOffService do
  let(:fake_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_zendesk_ticket) { double(ZendeskAPI::Ticket, id: 2) }
  let(:fake_zendesk_user) { double(ZendeskAPI::User, id: 1) }
  let(:comment_uploads) { [] }
  let(:default_comment_body) do
    <<~BODY
      New Dropoff at Adams City High School

      Certification Level: Basic and HSA
      Name: Gary Guava
      Phone number: (415) 816-1286
      Email: gguava@example.com
      Signature method: E-Signature
      Pickup Date: 4/10/2020
      Additional info: Gary is missing a document
    BODY
  end

  before do
    allow(ZendeskAPI::Client).to receive(:new).and_return(fake_zendesk_client)
    allow(ZendeskAPI::Ticket).to receive(:new).and_return(fake_zendesk_ticket)
    allow(ZendeskAPI::Ticket).to receive(:find).and_return(fake_zendesk_ticket)

    allow(fake_zendesk_client).to receive_message_chain(:users, :create).and_return(fake_zendesk_user)
    allow(fake_zendesk_ticket).to receive(:comment=)
    allow(fake_zendesk_ticket).to receive_message_chain(:comment, :uploads).and_return(comment_uploads)
    allow(fake_zendesk_ticket).to receive(:save)
  end

  describe "#create_ticket" do
    let(:drop_off) { create :full_drop_off }

    it "creates a new Zendesk ticket with info from the drop_off and attaches documents to ticket" do
      result = ZendeskDropOffService.new(drop_off).create_ticket

      expect(ZendeskAPI::Ticket).to have_received(:new).with(
        fake_zendesk_client,
        {
          subject: drop_off.name,
          requester_id: fake_zendesk_user.id,
          group_id: ZendeskDropOffService::TAX_HELP_COLORADO,
          comment: {
            body: default_comment_body,
          },
          fields: [
            {
              ZendeskDropOffService::CERTIFICATION_LEVEL => drop_off.certification_level,
              ZendeskDropOffService::HSA => drop_off.hsa,
              ZendeskDropOffService::INTAKE_SITE => "adams_city_high_school",
              ZendeskDropOffService::STATE => "co",
              ZendeskDropOffService::INTAKE_STATUS => "3._ready_for_prep",
              ZendeskDropOffService::SIGNATURE_METHOD => drop_off.signature_method,
            }
          ]
        }
      )
      expect(result).to eq 2
      expect(comment_uploads.first[:filename]).to eq "GaryGuava.pdf"
      expect(fake_zendesk_ticket).to have_received(:save)
    end
  end

  describe "#append_to_existing_ticket" do
    let(:drop_off) { create :full_drop_off, zendesk_ticket_id: "48" }

    before do
      allow(fake_zendesk_ticket).to receive(:save).and_return(true)
    end

    it "appends a comment and document to the ticket" do
      result = ZendeskDropOffService.new(drop_off).append_to_existing_ticket

      expect(ZendeskAPI::Ticket).to have_received(:find).with(fake_zendesk_client, id: "48")
      expect(fake_zendesk_ticket).to have_received(:comment=).with({body: default_comment_body})
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
          Additional info: Gary is missing a document
        BODY
        expect(result).to eq expected_body
      end
    end
  end
end
