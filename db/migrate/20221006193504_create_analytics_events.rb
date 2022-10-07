class CreateAnalyticsEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :analytics_events do |t|
      t.references :client, null: false, index: true, foreign_key: true
      t.string :event_type

      t.timestamps
      t.index [:event_type, :client_id]
    end
  end
end
