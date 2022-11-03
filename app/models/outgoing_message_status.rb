# == Schema Information
#
# Table name: outgoing_message_statuses
#
#  id              :bigint           not null, primary key
#  delivery_status :text
#  message_type    :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class OutgoingMessageStatus < ApplicationRecord
  enum message_type: { sms: 1 }

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
