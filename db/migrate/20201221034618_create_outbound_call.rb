class CreateOutboundCall < ActiveRecord::Migration[6.0]
  def change
    create_table :outbound_calls do |t|
      t.references :user
      t.references :client
      t.string :to_phone_number, null: false
      t.string :from_phone_number, null: false
      t.string :call_duration
      t.string :twilio_sid
      t.string :twilio_status
      t.datetime :completed_at
      t.timestamps
    end
  end
end
