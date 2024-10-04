class CreateStateFile1099Rs < ActiveRecord::Migration[7.1]
  def change
    create_table :state_file1099_rs do |t|
      t.string "payer_name_control", null: false
      t.string "payer_name", null: false
      t.string "payer_address_line1", null: false
      t.string "payer_address_line2", null: false
      t.string "payer_city_name", null: false
      t.string "payer_state_code", null: false
      t.string "payer_zip", null: false
      t.string "payer_identification_number", null: false
      t.string "phone_number", null: false
      t.integer "gross_distribution_amount", null: false
      t.integer "taxable_amount", null: false
      t.integer "federal_income_tax_withheld_amount", null: false
      t.string "distribution_code", null: false
      t.boolean "standard", null: false
      t.integer "state_tax_withheld_amount", null: false
      t.string "state_code", null: false
      t.string "payer_state_identification_number", null: false
      t.integer "state_distribution_amount", null: false
      t.string "recipient_ssn", null: false
      t.string "recipient_name", null: false
      t.boolean "taxable_amount_not_determined", null: false
      t.boolean "total_distribution", null: false
      t.integer "capital_gain_amount", null: false
      t.integer "designated_roth_account_first_year", null: false
      t.timestamps
    end
  end
end
