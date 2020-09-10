class CreateOutgoingEmail < ActiveRecord::Migration[6.0]
  def change
    create_table :outgoing_emails do |t|
      t.references :client, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :body, null: false
      t.string :subject, null: false
      t.datetime :sent_at, null: false

      t.timestamps
    end
  end
end
