require "rails_helper"

RSpec.describe ZendeskServiceHelper do
  let(:fake_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_zendesk_ticket) { double(ZendeskAPI::Ticket, id: 2) }
  let(:fake_zendesk_user) { double(ZendeskAPI::User, id: 1) }
  let(:service) do
    class SampleService
      include ZendeskServiceHelper
    end

    SampleService.new
  end

  before do
    allow(ZendeskAPI::Client).to receive(:new).and_return(fake_zendesk_client)
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
end