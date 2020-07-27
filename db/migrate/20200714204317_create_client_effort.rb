class CreateClientEffort < ActiveRecord::Migration[6.0]
  def change
    create_table :client_efforts do |t|
      t.belongs_to :intake, foreign_key: true, null: false
      t.bigint :ticket_id, null: false
      t.datetime :made_at, null: false
      t.string :effort_type, null: false
      t.datetime :responded_to_at
      t.string :response_type
      t.timestamps
    end
  end
end