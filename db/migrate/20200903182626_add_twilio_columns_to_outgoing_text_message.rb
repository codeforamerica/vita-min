class AddTwilioColumnsToOutgoingTextMessage < ActiveRecord::Migration[6.0]
  def change
    add_column :outgoing_text_messages, :twilio_sid, :string
    add_column :outgoing_text_messages, :twilio_status, :string
  end
end
