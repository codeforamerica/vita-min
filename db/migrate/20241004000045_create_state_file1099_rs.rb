class CreateStateFile1099Rs < ActiveRecord::Migration[7.1]
  def change
    create_table :state_file1099_rs do |t|
      t.string "payer_name_control"
      t.string "payer_name"
      t.string "payer_address_line1"
      t.string "payer_address_line2"
      t.string "payer_city_name"
      t.string "payer_state_code"
      t.string "payer_zip"
      t.string "payer_identification_number"
      t.string "phone_number"
      t.decimal "gross_distribution_amount", precision: 12, scale: 2
      t.decimal "taxable_amount", precision: 12, scale: 2
      t.decimal "federal_income_tax_withheld_amount", precision: 12, scale: 2
      t.string "distribution_code"
      t.boolean "standard"
      t.decimal "state_tax_withheld_amount", precision: 12, scale: 2
      t.string "state_code"
      t.string "payer_state_identification_number"
      t.decimal "state_distribution_amount", precision: 12, scale: 2
      t.string "recipient_ssn"
      t.string "recipient_name"
      t.boolean "taxable_amount_not_determined"
      t.boolean "total_distribution"
      t.decimal "capital_gain_amount", precision: 12, scale: 2
      t.integer "designated_roth_account_first_year"

      t.references :intake, polymorphic: true, null: false
      t.references :state_specific_followup, polymorphic: true, null: true

      t.timestamps
    end
  end
end
