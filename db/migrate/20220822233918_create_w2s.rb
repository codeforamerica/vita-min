class CreateW2s < ActiveRecord::Migration[7.0]
  def change
    create_table :w2s do |t|
      t.string :legal_first_name
      t.string :legal_middle_initial
      t.string :legal_last_initial
      t.string :suffix
      t.string :employee_ssn
      t.decimal :wages_amount, precision: 12, scale: 2
      t.string :employee_street_adddress
      t.string :employee_apartment_number
      t.string :employee_city
      t.string :employee_state
      t.string :employee_zip_code
      t.string :employer_ein
      t.string :employer_name
      t.string :employer_street_address
      t.string :employer_apartment_number
      t.string :employer_city
      t.string :employer_state
      t.string :employer_zip_code
      t.string :employer_name_control_text
      t.string :standard_or_non_standard_code
      t.references :intake

      t.timestamps
    end
  end
end
