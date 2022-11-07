# == Schema Information
#
# Table name: outgoing_message_statuses
#
#  id              :bigint           not null, primary key
#  delivery_status :text
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
class OutgoingMessageStatus < ApplicationRecord
  enum message_type: { sms: 1, email: 2 }

  def update_status_if_further(new_status)
    with_lock do
      old_index = TwilioService::ORDERED_STATUSES.index(delivery_status)
      new_index = TwilioService::ORDERED_STATUSES.index(new_status)

      if new_index > old_index
        update(delivery_status: new_status)
      end
    end
  end
end
