class AddCompletedTaxReturnTables < ActiveRecord::Migration[7.1]
  def change
    create_table :completed_2023_tax_return_logs do |t|
      t.references :completed_2023_tax_return, foreign_key: true
      t.integer "event_type", null: false
      t.inet "ip_address"
      t.timestamps
    end

    create_table :completed_2023_tax_return_pdfs do |t|
      t.references :completed_2023_tax_return, null: false, foreign_key: true
    end
  end
end
