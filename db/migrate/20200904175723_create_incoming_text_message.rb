class CreateIncomingTextMessage < ActiveRecord::Migration[6.0]
  def change
    create_table :incoming_text_messages do |t|
      t.references :case_file, null: false, foreign_key: true
      t.string :body, null: false
      t.datetime :received_at, null: false
      t.string :from_phone_number, null: false

      t.timestamps
    end
  end
end
