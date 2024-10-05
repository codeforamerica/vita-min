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
      t.integer "gross_distribution_amount"
      t.integer "taxable_amount"
      t.integer "federal_income_tax_withheld_amount"
      t.string "distribution_code"
      t.boolean "standard"
      t.integer "state_tax_withheld_amount"
      t.string "state_code"
      t.string "payer_state_identification_number"
      t.integer "state_distribution_amount"
      t.string "recipient_ssn"
      t.string "recipient_name"
      t.boolean "taxable_amount_not_determined"
      t.boolean "total_distribution"
      t.integer "capital_gain_amount"
      t.integer "designated_roth_account_first_year"

      t.references :intake, polymorphic: true, null: false
      t.references :state_specific_followup, polymorphic: true, null: true

      t.timestamps
    end
  end
end
