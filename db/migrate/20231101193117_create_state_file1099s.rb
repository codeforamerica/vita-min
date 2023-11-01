class CreateStateFile1099s < ActiveRecord::Migration[7.1]
  def change
    create_table :state_file1099s do |t|
      t.string :payer_name
      t.integer :payer_name_is_default, default: 0, null: false
      t.integer :recipient, default: 0, null: false
      t.integer :address_confirmation, default: 0, null: false
      t.string :recipient_street_address
      t.string :recipient_zip
      t.string :recipient_city
      t.string :recipient_state
      t.integer :unemployment_compensation
      t.integer :federal_income_tax_withheld
      t.integer :state_income_tax_withheld
      t.references :intake, polymorphic: true, null: false

      t.timestamps
    end
  end
end
