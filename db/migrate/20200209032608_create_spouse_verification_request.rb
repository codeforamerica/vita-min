class CreateSpouseVerificationRequest < ActiveRecord::Migration[5.2]
  def change
    create_table :spouse_verification_requests do |t|
      t.bigint :zendesk_ticket_id
      t.bigint :zendesk_requester_id
      t.datetime :sent_at
      t.string :email
      t.string :phone_number
      t.references :intake, index: true, null: false
      t.references :user, index: true
      t.timestamps
    end
  end
end
