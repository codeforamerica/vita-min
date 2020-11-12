class CreateSystemNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :system_notes do |t|
      t.text :body
      t.references :client, null: false, foreign_key: true, index: true
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
