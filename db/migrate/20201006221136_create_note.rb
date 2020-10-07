class CreateNote < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.text :body
      t.references :client, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
