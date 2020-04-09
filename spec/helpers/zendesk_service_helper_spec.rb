require "rails_helper"

RSpec.describe ZendeskServiceHelper do
  let(:fake_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_zendesk_ticket) { double(ZendeskAPI::Ticket, id: 2, errors: nil) }
  let(:fake_zendesk_user) { double(ZendeskAPI::User, id: 1) }
  let(:fake_zendesk_comment) { double(uploads: []) }
  let(:service) do
    class SampleService
      include ZendeskServiceHelper

      def instance
        EitcZendeskInstance
      end
    end

    SampleService.new
  end

  before do
    allow(ZendeskAPI::Client).to receive(:new).and_return fake_zendesk_client
    allow(ZendeskAPI::Ticket).to receive(:new).and_return fake_zendesk_ticket
    allow(ZendeskAPI::Ticket).to receive(:find).and_return fake_zendesk_ticket
    allow(fake_zendesk_ticket).to receive(:comment=)
    allow(fake_zendesk_ticket).to receive(:fields=)
    allow(fake_zendesk_ticket).to receive(:group_id=)
    allow(fake_zendesk_ticket).to receive(:comment).and_return fake_zendesk_comment
    allow(fake_zendesk_ticket).to receive(:save).and_return true
  end

  describe "#find_end_user" do
    let(:search_results) { [fake_zendesk_user] }

    before do
      allow(service).to receive(:search_zendesk_users).with(kind_of(String)).and_return(search_results)
    end

    context "when email is present" do
      it "searches by email" do
        result = service.find_end_user(nil, "test@example.com", nil)
        expect(service).to have_received(:search_zendesk_users).with("email:test@example.com")
        expect(result).to eq(1)
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
        expect(service).to have_received(:search_zendesk_users).with("name:\"Gary Guava\" ")
      end
    end

    context "when only phone is present" do
      it "searches with only phone" do
        service.find_end_user(nil, nil, "14155555555")
        expect(service).to have_received(:search_zendesk_users).with("phone:14155555555")
      end
    end

    context "when there are no search results" do
      let(:search_results) { [] }
      it "returns nil" do
        result = service.find_end_user("Gary Guava", "test@example.com", "14155555555")
        expect(result).to eq nil
      end
    end

    context "when we need an exact match" do
      let(:match_with_extra_phone) { double(ZendeskAPI::User, id: 5, name: "Percy Plum", phone: "14155554321", email: nil) }
      let(:match_with_extra_email) { double(ZendeskAPI::User, id: 6, name: "Percy Plum", phone: nil, email: "shoe@hoof.horse") }
      let(:exact_match) { double(ZendeskAPI::User, id: 9, name: "Percy Plum", email: nil, phone: nil) }

      context "and it exists" do
        let(:search_results) { [match_with_extra_phone, match_with_extra_email, exact_match] }

        it "returns the id of the exact match" do
          result = service.find_end_user("Percy Plum", nil, nil, exact_match: true)
          expect(result).to eq 9
        end
      end

      context "and only partial matches exist" do
        let(:search_results) { [match_with_extra_phone, match_with_extra_email] }

        it "returns the id of the exact match" do
          result = service.find_end_user("Percy Plum", nil, nil, exact_match: true)
          expect(result).to eq nil
        end
      end
    end
  end

  describe "#find_or_create_end_user" do
    before do
      allow(service).to receive(:find_end_user).and_return(result)
    end

    context "end user exists" do
      let(:result) { 1 }

      it "returns the existing user's id" do
        expect(service.find_or_create_end_user("Nancy Nectarine", nil, nil)).to eq 1
      end
    end

    context "end user does not exist" do
      let(:result) { nil }

      before do
        allow(service).to receive(:create_end_user).and_return(fake_zendesk_user)
      end

      it "creates new user and returns their id" do
        expect(service.find_or_create_end_user("Nancy Nectarine", nil, nil)).to eq 1
        expect(service).to have_received(:create_end_user).with(
          name: "Nancy Nectarine",
          email: nil,
          phone: nil,
          time_zone: nil
        )
      end
    end
  end

  describe "#build_ticket" do
    let(:ticket_args) do
      {
        subject: "wyd",
        requester_id: 4,
        group_id: "123409218",
        body: "What's up?",
        fields: {
          "09182374" => "not_busy"
        }
      }
    end

    it "correctly calls the Zendesk API and returns a ticket object" do
      result = service.build_ticket(**ticket_args)

      expect(result).to eq fake_zendesk_ticket
      expect(ZendeskAPI::Ticket).to have_received(:new).with(
        fake_zendesk_client,
        {
          subject: "wyd",
          requester_id: 4,
          group_id: "123409218",
          external_id: nil,
          comment: {
            body: "What's up?",
          },
          fields: [
            "09182374" => "not_busy"
          ]
        }
      )
    end
  end

  describe "#create_ticket" do
    let(:success) { true }
    let(:errors) { nil }
    let(:ticket_args) do
      {
        subject: "wyd",
        requester_id: 4,
        group_id: "123409218",
        external_id: "some-object-123",
        body: "What's up?",
        fields: {
          "09182374" => "not_busy"
        }
      }
    end

    before do
      allow(service).to receive(:build_ticket).and_return(fake_zendesk_ticket)
      allow(fake_zendesk_ticket).to receive(:save).and_return(success)
      allow(fake_zendesk_ticket).to receive(:errors).and_return(errors)
    end

    it "calls build_ticket, saves the ticket, and returns the ticket id" do
      result = service.create_ticket(**ticket_args)
      expect(result).to eq 2
      expect(fake_zendesk_ticket).to have_received(:save).with(no_args)
      expect(service).to have_received(:build_ticket).with(**ticket_args)
    end

    describe "when the API returns an error" do
      let(:success) { false }
      let(:errors) { "Zendesk API failed for some reason" }

      it "raises an error" do
        expect do
          service.create_ticket(**ticket_args)
        end.to raise_error(ZendeskServiceHelper::ZendeskAPIError, /Error.*some reason/)
      end
    end
  end

  describe "#assign_ticket_to_group" do
    it "finds the ticket and updates the group id" do
      result = service.assign_ticket_to_group(ticket_id: 123, group_id: "12543")

      expect(result).to eq true
      expect(fake_zendesk_ticket).to have_received(:group_id=).with("12543")
      expect(fake_zendesk_ticket).to have_received(:save).with(no_args)
    end
  end

  describe "#append_file_to_ticket" do
    let(:file) { instance_double(File) }

    it "calls the Zendesk API to get the ticket and add the comment with upload and returns true" do
      result = service.append_file_to_ticket(
        ticket_id: 1141,
        filename: "wyd.jpg",
        file: file,
        comment: "hey",
        fields: { "314324132" => "custom_field_value" }
      )
      expect(result).to eq true
      expect(fake_zendesk_ticket).to have_received(:comment=).with({ body: "hey" })
      expect(fake_zendesk_ticket).to have_received(:fields=).with({ "314324132" => "custom_field_value" })
      expect(fake_zendesk_comment.uploads).to include({file: file, filename: "wyd.jpg"})
      expect(fake_zendesk_ticket).to have_received(:save)
    end

    context "when the ticket id is missing" do
      it "raises an error" do
        expect do
          service.append_file_to_ticket(
            ticket_id: nil,
            filename: "yolo.pdf",
            file: file
          )
        end.to raise_error(ZendeskServiceHelper::MissingTicketIdError)
      end
    end
  end

  describe "#append_comment_to_ticket" do
    it "calls the Zendesk API to get the ticket and add the comment" do
      result = service.append_comment_to_ticket(
        ticket_id: 1141,
        comment: "hey this is a comment",
        fields: { "314324132" => "custom_field_value" }
      )

      expect(result).to eq true
      expect(fake_zendesk_ticket).to have_received(:comment=).with({ body: "hey this is a comment", public: false })
      expect(fake_zendesk_ticket).to have_received(:fields=).with({ "314324132" => "custom_field_value" })
      expect(fake_zendesk_ticket).to have_received(:save)
    end
  end

  describe "#get_ticket" do
    it "calls the Zendesk API to get the details for a given ticket id" do
      service.get_ticket(ticket_id: 1141)

      expect(ZendeskAPI::Ticket).to have_received(:find).with(fake_zendesk_client, id: 1141)
    end
  end
end
