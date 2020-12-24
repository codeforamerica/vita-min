class ChangeCallDurationToInteger < ActiveRecord::Migration[6.0]
  def change
    remove_column :outbound_calls, :call_duration
    add_column :outbound_calls, :twilio_call_duration, :integer
  end
end
