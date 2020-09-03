class CreateOutgoingTextMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :outgoing_text_messages do |t|
      t.references :case_file, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :body, null: false
      t.datetime :sent_at, null: false

      t.timestamps
    end
  end
end
