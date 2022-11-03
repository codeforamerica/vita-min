class CreateOutgoingMessageStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :outgoing_message_statuses do |t|
      t.text :delivery_status
      t.integer :message_type, null: false

      t.timestamps
    end
  end
end
