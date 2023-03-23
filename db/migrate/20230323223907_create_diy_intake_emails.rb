class CreateDiyIntakeEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :diy_intake_emails do |t|
      t.string "mailgun_status", default: "sending"
      t.string "message_id"
      t.datetime "sent_at", precision: nil
      t.references "diy_intake"

      t.timestamps
    end
  end
end
