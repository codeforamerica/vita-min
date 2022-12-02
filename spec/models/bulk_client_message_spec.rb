# == Schema Information
#
# Table name: bulk_client_messages
#
#  id                      :bigint           not null, primary key
#  cached_data             :jsonb
#  send_only               :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  tax_return_selection_id :bigint
#
# Indexes
#
#  index_bcm_on_tax_return_selection_id  (tax_return_selection_id)
#
# Foreign Keys
#
#  fk_rails_...  (tax_return_selection_id => tax_return_selections.id)
#
require "rails_helper"

RSpec.describe BulkClientMessage, type: :model do
  let(:one_success) do
    client = create(:outgoing_text_message, twilio_status: "delivered").client
    create(:gyr_tax_return, client: client)
  end
  let(:two_successes) do
    client = create(:outgoing_text_message, twilio_status: "sent").client
    create(:outgoing_email, client: client, mailgun_status: "opened").client
    create(:gyr_tax_return, client: client)
  end
  let(:one_fail) do
    client = create(:outgoing_text_message, twilio_status: "failed").client
    create(:gyr_tax_return, client: client)
  end
  let(:one_fail_one_success) do
    client = create(:outgoing_text_message, twilio_status: "sent").client
    create(:outgoing_email, client: client, mailgun_status: "permanent_fail").client
    create(:gyr_tax_return, client: client)
  end
  let(:no_messages) do
    create(:gyr_tax_return, client: (create :client))
  end
  let(:in_progress) do
    client = create(:outgoing_email, mailgun_status: "sending").client
    create(:gyr_tax_return, client: client)
  end
  let(:one_nil_status_one_fail) do
    client = create(:outgoing_text_message, twilio_status: nil).client
    create(:outgoing_email, client: client, mailgun_status: "permanent_fail").client
    create(:gyr_tax_return, client: client)
  end
  let!(:tax_return_selection) do
    create :tax_return_selection, tax_returns: [one_success, two_successes, one_fail, one_fail_one_success, no_messages, in_progress, one_nil_status_one_fail]
  end
  let(:bulk_client_message) do
    create :bulk_client_message, outgoing_emails: OutgoingEmail.all, outgoing_text_messages: OutgoingTextMessage.all, tax_return_selection: tax_return_selection
  end

  describe "#flush_memoized_data" do
    it "updates and uses the cache when the task is completed" do
      bulk_client_message.flush_memoized_data
      expect(bulk_client_message.status).to eq(BulkClientMessage::IN_PROGRESS)
      expect(bulk_client_message.cached_data).to eq({})

      in_progress.client.outgoing_emails.first.update!(mailgun_status: 'delivered')
      one_nil_status_one_fail.client.outgoing_text_messages.first.update!(twilio_status: 'sent')

      bulk_client_message.reload
      bulk_client_message.flush_memoized_data
      expect(bulk_client_message.status).to eq(BulkClientMessage::FAILED)
      expect(bulk_client_message.cached_data).to eq(
                                                   'clients_with_in_progress_messages_count' => 0,
                                                   'clients_with_no_successfully_sent_messages_count' => 2
                                                 )
    end
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
