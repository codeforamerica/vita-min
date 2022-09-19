class AddAnalyticsJourneysTable < ActiveRecord::Migration[7.0]
  def change
    create_table :analytics_journeys do |t|
      t.string :w2_logout_add_later
      t.references :client, null: false, foreign_key: true
      t.timestamps
    end
  end
end
