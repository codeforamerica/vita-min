# == Schema Information
#
# Table name: bulk_client_messages
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  client_selection_id     :bigint
#  tax_return_selection_id :bigint
#
# Indexes
#
#  index_bcm_on_tax_return_selection_id               (tax_return_selection_id)
#  index_bulk_client_messages_on_client_selection_id  (client_selection_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_selection_id => client_selections.id)
#  fk_rails_...  (tax_return_selection_id => tax_return_selections.id)
#
require "rails_helper"

RSpec.describe BulkClientMessage, type: :model do
  let(:one_success) do
    client = create(:outgoing_text_message, twilio_status: "delivered").client
    create(:tax_return, client: client)
  end
  let(:two_successes) do
    client = create(:outgoing_text_message, twilio_status: "sent").client
    create(:outgoing_email, client: client, mailgun_status: "opened").client
    create(:tax_return, client: client)
  end
  let(:one_fail) do
    client = create(:outgoing_text_message, twilio_status: "failed").client
    create(:tax_return, client: client)
  end
  let(:one_fail_one_success) do
    client = create(:outgoing_text_message, twilio_status: "sent").client
    create(:outgoing_email, client: client, mailgun_status: "permanent_fail").client
    create(:tax_return, client: client)
  end
  let(:no_messages) do
    create(:tax_return, client: (create :client))
  end
  let(:in_progress) do
    client = create(:outgoing_email, mailgun_status: "sending").client
    create(:tax_return, client: client)
  end
  let(:one_nil_status_one_fail) do
    client = create(:outgoing_text_message, twilio_status: nil).client
    create(:outgoing_email, client: client, mailgun_status: "permanent_fail").client
    create(:tax_return, client: client)
  end
  let!(:tax_return_selection) do
    create :tax_return_selection, tax_returns: [one_success, two_successes, one_fail, one_fail_one_success, no_messages, in_progress, one_nil_status_one_fail]
  end
  let(:bulk_client_message) do
    create :bulk_client_message, outgoing_emails: OutgoingEmail.all, outgoing_text_messages: OutgoingTextMessage.all, tax_return_selection: tax_return_selection
  end

  describe "#clients_with_no_successfully_sent_messages" do
    it "returns the right clients" do
      result = bulk_client_message.clients_with_no_successfully_sent_messages
      expect(result).to match_array [one_fail, no_messages].map(&:client)
    end
  end

  describe "#clients_with_successfully_sent_messages" do
    it "returns the right clients" do
      result = bulk_client_message.clients_with_successfully_sent_messages
      expect(result).to match_array [one_success, two_successes, one_fail_one_success].map(&:client)
    end
  end

  describe "#clients_with_in_progress_messages" do
    it "returns the right clients" do
      result = bulk_client_message.clients_with_in_progress_messages
      expect(result).to match_array [in_progress, one_nil_status_one_fail].map(&:client)
    end
  end
end
