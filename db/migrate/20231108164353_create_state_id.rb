class CreateStateId < ActiveRecord::Migration[7.1]
  def change
    create_table :state_ids do |t|
      t.timestamps
      t.integer :id_type, default: 0, null: false
      t.string :id_number
      t.string :state
      t.date :issue_date
      t.date :expiration_date
      t.string :first_three_doc_num
    end
  end
end
