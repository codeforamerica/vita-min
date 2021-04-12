require "rails_helper"

describe BulkClientMessagingJob, type: :job do
  let(:message_body_en) { "Hey how's it going?" }
  let(:message_body_es) { "Oye como va?" }
  let!(:client_selection) { create :client_selection }
  let(:user) { create :admin_user }
  before do
    allow(ClientMessagingService).to receive(:send_message_to_all_opted_in_contact_methods)
  end

  describe "#perform" do
    context "with messages for both locales" do
      let!(:client_es) { create :client, client_selections: [client_selection], intake: create(:intake, locale: "es") }
      let!(:client_en) { create :client, client_selections: [client_selection], intake: create(:intake, locale: "en") }
      let!(:client_nil) { create :client, client_selections: [client_selection], intake: create(:intake, locale: nil) }

      it "sends messages to clients with the appropriate locales" do
        described_class.perform_now(client_selection, user, en: message_body_en, es: message_body_es)
        expect(ClientMessagingService).to have_received(:send_message_to_all_opted_in_contact_methods).with(
          client_es, user, message_body_es
        )
        expect(ClientMessagingService).to have_received(:send_message_to_all_opted_in_contact_methods).with(
          client_en, user, message_body_en
        )
        expect(ClientMessagingService).to have_received(:send_message_to_all_opted_in_contact_methods).with(
          client_nil, user, message_body_en
        )
      end
    end

    context "with one message body" do
      context "and one matching locale among clients" do
        let!(:client_es) { create :client, client_selections: [client_selection], intake: create(:intake, locale: "es") }

        it "sends messages to the clients without problems" do
          described_class.perform_now(client_selection, user, es: message_body_es)

          expect(ClientMessagingService).to have_received(:send_message_to_all_opted_in_contact_methods).with(
            client_es, user, message_body_es
          )
        end
      end

      context "and two locales among clients" do
        let!(:client_es) { create :client, client_selections: [client_selection], intake: create(:intake, locale: "es") }
        let!(:client_en) { create :client, client_selections: [client_selection], intake: create(:intake, locale: "en") }

        it "raises an error" do
          expect do
            described_class.perform_now(client_selection, user, es: message_body_es)
          end.to raise_error(ArgumentError)
        end
      end
    end

    context "when the sender can't access some of the clients" do
      let(:organization) { create :organization }
      let(:other_org) { create :organization }
      let(:user) { create :organization_lead_user, organization: organization }
      let!(:accessible_client) { create(:intake, client: create(:client, client_selections: [client_selection], vita_partner: organization)).client }
      let!(:inaccessible_client) { create(:intake, client: create(:client, client_selections: [client_selection], vita_partner: other_org)).client }

      it "scopes down to only the accessible clients" do
        described_class.perform_now(client_selection, user, en: message_body_en)
        expect(ClientMessagingService).to have_received(:send_message_to_all_opted_in_contact_methods).with(
          accessible_client, user, message_body_en
        )
        expect(ClientMessagingService).not_to have_received(:send_message_to_all_opted_in_contact_methods).with(
          inaccessible_client, user, message_body_en
        )
      end
    end
  end
end