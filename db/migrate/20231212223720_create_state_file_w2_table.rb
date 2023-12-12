class CreateStateFileW2Table < ActiveRecord::Migration[7.1]
  def change
    create_table :state_file_w2_tables do |t|
      t.references :intake, polymorphic: true, index: true
      t.string :employee_ssn
      t.string :employer_ein
      t.string :employer_name
      t.string :employer_street_address
      t.string :employer_city
      t.string :employer_state
      t.string :employer_zip_code
      t.integer :wages_amount
      t.integer :box8_allocated_tips
      t.integer :box10_dependent_care_benefits
      t.integer :box11_nonqualified_plans
      t.string :box12a_code
      t.integer :box12a_value
      t.string :box12b_code
      t.integer :box12b_value
      t.string :box12c_code
      t.integer :box12c_value
      t.string :box12d_code
      t.integer :box12d_value
      t.string :box13_retirement_plan
      t.string :box13_third_party_sick_pay
      t.integer :box16_state_wages
      t.integer :box17_state_income_tax
      t.integer :box18_local_wages
      t.integer :box19_local_income_tax
      t.string :box20_locality_name
      t.string :box14a_other_description
      t.integer :box14a_other_amount
      t.string :box14b_other_description
      t.integer :box14b_other_amount
      t.string :box14c_other_description
      t.integer :box14c_other_amount
      t.string :box14d_other_description
      t.integer :box14d_other_amount

      t.timestamps
    end
  end
end
