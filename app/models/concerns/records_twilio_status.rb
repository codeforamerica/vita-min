module RecordsTwilioStatus
  extend ActiveSupport::Concern

  def update_status_if_further(new_status)
    with_lock do
      old_status = read_attribute(self.class.status_column)
      old_index = TwilioService::ORDERED_STATUSES.index(old_status)
      new_index = TwilioService::ORDERED_STATUSES.index(new_status)

      if new_index > old_index
        update(self.class.status_column => new_status)
      end
    end
  end
end
