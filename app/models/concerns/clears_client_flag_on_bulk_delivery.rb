module ClearsClientFlagOnBulkDelivery
  extend ActiveSupport::Concern

  included do
    after_update_commit :clear_client_flag_if_bulk_delivery_succeeded
  end

  private

  def clear_client_flag_if_bulk_delivery_succeeded
    return unless saved_change_to_attribute?(self.class.status_column)
    return unless delivery_succeeded?
    return unless sent_as_bulk_message?
    return unless client&.flagged?
    return unless client.flagged_at < created_at

    client.clear_flag!
  end
end
