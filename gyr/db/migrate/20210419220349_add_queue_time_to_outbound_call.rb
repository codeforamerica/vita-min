class AddQueueTimeToOutboundCall < ActiveRecord::Migration[6.0]
  def change
    add_column :outbound_calls, :queue_time_ms, :integer
  end
end
