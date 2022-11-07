# == Schema Information
#
# Table name: bulk_signup_messages
#
#  id                  :bigint           not null, primary key
#  message             :text             not null
#  message_type        :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  signup_selection_id :bigint           not null
#  user_id             :bigint           not null
#
# Indexes
#
#  index_bulk_signup_messages_on_signup_selection_id  (signup_selection_id)
#  index_bulk_signup_messages_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (signup_selection_id => signup_selections.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

describe BulkSignupMessage do
  describe "#status" do
    let(:bulk_signup_message) { create(:bulk_signup_message, message_type: message_type, signup_selection: signup_selection) }
    let(:signup_selection) { build(:signup_selection, id_array: [signup.id]) }
    let!(:signup) { create :signup }

    context 'sms' do
      let(:message_type) { 'sms' }
      let!(:bsmoms_sms) { BulkSignupMessageOutgoingMessageStatus.create(bulk_signup_message: bulk_signup_message, outgoing_message_status: outgoing_sms)}
      let!(:outgoing_sms) { create(:outgoing_message_status, parent: signup, message_type: message_type, delivery_status: delivery_status) }

      context "when some of the messages are still in progress" do
        let(:delivery_status) { 'queued' }

        it "returns false" do
          expect(bulk_signup_message.sending_complete?).to be_falsey
        end
      end

      context "when none of the messages are still in progress" do
        let(:delivery_status) { 'sent' }

        it "returns true" do
          expect(bulk_signup_message.sending_complete?).to be_truthy
        end
      end
    end

    context 'email' do
      let(:message_type) { 'email' }
      let!(:bsmoms_email) { BulkSignupMessageOutgoingMessageStatus.create(bulk_signup_message: bulk_signup_message, outgoing_message_status: outgoing_email)}
      let!(:outgoing_email) { create(:outgoing_message_status, parent: signup, message_type: message_type, delivery_status: delivery_status) }

      context "when some of the messages are still in progress" do
        let(:delivery_status) { 'sending' }

        it "returns false" do
          expect(bulk_signup_message.sending_complete?).to be_falsey
        end
      end

      context "when none of the messages are still in progress" do
        let(:delivery_status) { 'delivered' }

        it "returns true" do
          expect(bulk_signup_message.sending_complete?).to be_truthy
        end
      end
    end
  end
end
