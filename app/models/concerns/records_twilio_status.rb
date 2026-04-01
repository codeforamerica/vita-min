module RecordsTwilioStatus
  extend ActiveSupport::Concern

  def update_status_if_further(new_status, error_code: nil)
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
        if %w[sent delivered delivery_unknown undelivered failed].include?(new_status) && has_attribute?(:sent_at)
          attrs[:sent_at] = Time.current
        end
        update(attrs)
      end
    end
  end
end
