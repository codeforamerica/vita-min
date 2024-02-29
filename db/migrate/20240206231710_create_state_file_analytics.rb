class CreateStateFileAnalytics < ActiveRecord::Migration[7.1]
  def change
    create_table :state_file_analytics do |t|
      t.references :record, polymorphic: true, null: false
      t.integer :filing_status
      t.integer :fed_eitc_amount
      t.integer :refund_or_owed_amount

      t.timestamps
    end
  end
end
