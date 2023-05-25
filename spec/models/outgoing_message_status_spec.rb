# == Schema Information
#
# Table name: outgoing_message_statuses
#
#  id              :bigint           not null, primary key
#  delivery_status :text
#  error_code      :string
#  message_type    :integer          not null
#  parent_type     :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  message_id      :text
#  parent_id       :bigint           not null
#
# Indexes
#
#  index_outgoing_message_statuses_on_parent  (parent_type,parent_id)
#
require 'rails_helper'

RSpec.describe OutgoingMessageStatus, type: :model do
  describe "#update_status_if_further" do
    let(:subject) { create(:outgoing_message_status, :sms, delivery_status: delivery_status) }

    context "when updating to a later status" do
      let(:delivery_status) { "sending" }
      it "saves the change" do
        expect {
          subject.update_status_if_further("sent")
        }.to change(subject, :delivery_status).from("sending").to("sent")
      end
    end

    context "when updating to an earlier status" do
      let(:delivery_status) { "sent" }

      it "does not save" do
        expect {
          subject.update_status_if_further("sending")
        }.not_to change(subject, :delivery_status)
      end
    end
  end
end
