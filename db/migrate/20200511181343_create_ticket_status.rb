class CreateTicketStatus < ActiveRecord::Migration[6.0]
  def change
    create_table :ticket_statuses do |t|
      t.string :intake_status, null: false
      t.string :return_status, null: false
      t.belongs_to :intake, foreign_key: true
      t.timestamps
    end
  end
end
