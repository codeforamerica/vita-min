class CreateSystemEmails < ActiveRecord::Migration[6.0]
  def change
    create_table :system_emails do |t|
      t.string :body, null: false
      t.datetime :sent_at, null: false
      t.string :subject, null: false
      t.string :to, null: false
      t.bigint :client_id, null: false
      t.timestamps
    end
  end
end
