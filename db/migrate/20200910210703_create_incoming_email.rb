class CreateIncomingEmail < ActiveRecord::Migration[6.0]
  def change
    create_table :incoming_emails do |t|
      t.references :client, null: false
      t.datetime :received_at, null: false
      t.string :to, null: false
      t.string :from, null: false
      t.string :sender, null: false
      t.string :recipient, null: false
      t.string :subject
      t.string :body_html
      t.string :body_plain, null: false
      t.string :stripped_html
      t.string :stripped_text
      t.string :stripped_signature
      t.string :user_agent
      t.string :received
      t.string :message_id
      t.integer :attachment_count
      t.timestamps
    end
  end
end
