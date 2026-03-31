module RecordsTwilioStatus
  extend ActiveSupport::Concern

  def update_status_if_further(new_status, error_code: nil, sent_at: nil)
    with_lock do
      old_status = read_attribute(self.class.status_column)
      old_index = TwilioService::ORDERED_STATUSES.index(old_status)
      new_index = TwilioService::ORDERED_STATUSES.index(new_status)

      if new_index.nil?
        Rails.logger.warn("Unknown Twilio status received: #{new_status.inspect}")
        return
      end

      old_index ||= 0

      if new_index > old_index
        attrs = { self.class.status_column => new_status, error_code: error_code }
        attrs[:sent_at] = sent_at if %w[sent delivered].include?(new_status) && sent_at.present?
        update(attrs)
      end
    end
  end
end
