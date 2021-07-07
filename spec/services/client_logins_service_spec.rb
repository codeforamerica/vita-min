require "rails_helper"

describe ClientLoginsService do
  describe ".clients_for_token" do
    let(:service_type) { "online_intake" }
    let!(:tax_return) { create :tax_return, service_type: service_type }
    let!(:client) { create :client, login_token: login_token, tax_returns: [tax_return] }
    let(:login_token) { nil }

    before do
      allow(Devise.token_generator).to receive(:digest).and_return("hashed_token")
    end

    context "with a client with a matching token" do
      let(:login_token) { "hashed_token" }

      it "returns the client" do
        expect(described_class.clients_for_token("raw_token")).to match_array [client]
      end
    end

    context "with a client matching a TextMessageAccessToken" do
      before do
        create(:text_message_access_token, token: "hashed_token", sms_phone_number: "+16505551212")
        create(:intake, :primary_consented, client: client, sms_phone_number: "+16505551212")
      end

      it "returns the client" do
        expect(described_class.clients_for_token("raw_token")).to match_array [client]
      end
    end

    context "with a client whose email matches an EmailAccessToken" do
      before do
        create(:email_access_token, token: "hashed_token", email_address: "someone@example.com")
        create(:intake, :primary_consented, client: client, email_address: "someone@example.com")
      end

      it "returns the client" do
        expect(described_class.clients_for_token("raw_token")).to match_array [client]
      end
    end

    context "with a client whose spouse email matches an EmailAccessToken" do
      before do
        create(:email_access_token, token: "hashed_token", email_address: "someone@example.com")
        create(:intake, :primary_consented, client: client, spouse_email_address: "someone@example.com")
      end

      it "returns the client" do
        expect(described_class.clients_for_token("raw_token")).to match_array [client]
      end
    end

    context "with a client whose email is contained in a comma-separated EmailAccessToken" do
      before do
        create(:email_access_token, token: "hashed_token", email_address: "someone@example.com,other@example.com")
        create(:intake, :primary_consented, client: client, email_address: "someone@example.com")
      end

      it "returns the client" do
        expect(described_class.clients_for_token("raw_token")).to match_array [client]
      end
    end

    context "with a client with matching access tokens older than 2 days" do
      let!(:client) { create :client }
      before do
        create(:email_access_token, token: "hashed_token", email_address: "someone@example.com", created_at: Time.current - (2.1).days)
        create(:text_message_access_token, token: "hashed_token", sms_phone_number: "+16505551212", created_at: Time.current - (2.1).days)
        create(:intake, :primary_consented, client: client, spouse_email_address: "someone@example.com", sms_phone_number: "+16505551212")
      end

      it "returns a blank set" do
        expect(described_class.clients_for_token("raw_token")).to match_array []
      end
    end

    context "with no matching token" do
      it "returns a blank set" do
        expect(described_class.clients_for_token("raw_token")).to match_array []
      end
    end

    context "with a client with no consent to service" do
      before do
        create(:email_access_token, token: "hashed_token", email_address: "someone@example.com")
        create(:text_message_access_token, token: "hashed_token", sms_phone_number: "+16505551212")
        create(:intake, client: client, spouse_email_address: "someone@example.com", sms_phone_number: "+16505551212")
      end

      it "returns a blank set" do
        expect(described_class.clients_for_token("raw_token")).to match_array []
      end

      context "with a client that is a drop off" do
        let(:service_type) { "drop_off" }

        it "returns the client" do
          expect(described_class.clients_for_token("raw_token")).to match_array [client]
        end
      end
    end
  end
end
