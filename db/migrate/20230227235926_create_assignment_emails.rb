class CreateAssignmentEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :assignment_emails do |t|
      t.timestamp :assigned_at
      t.references :assigned_user, foreign_key: { to_table: 'users' }
      t.references :assigning_user, foreign_key: { to_table: 'users' }
      t.references :tax_return, null: false, foreign_key: true
      t.string :mailgun_status, default: "sending"
      t.string :message_id
      t.timestamp :sent_at

      t.timestamps
    end
  end
end
