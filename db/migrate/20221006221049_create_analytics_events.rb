class CreateAnalyticsEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :analytics_events do |t|
      t.timestamps

      t.references :client, null: false, foreign_key: true
      t.string :event_type
    end
    add_index :analytics_events, [:event_type, :client_id]
  end
end
