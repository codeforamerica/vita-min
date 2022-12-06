class Create2023W2 < ActiveRecord::Migration[7.0]
  def change
    create_table :w2s do |t|
      t.decimal "box10_dependent_care_benefits", precision: 12, scale: 2
      t.decimal "box11_nonqualified_plans", precision: 12, scale: 2
      t.string "box12a_code"
      t.decimal "box12a_value", precision: 12, scale: 2
      t.string "box12b_code"
      t.decimal "box12b_value", precision: 12, scale: 2
      t.string "box12c_code"
      t.decimal "box12c_value", precision: 12, scale: 2
      t.string "box12d_code"
      t.decimal "box12d_value", precision: 12, scale: 2
      t.integer "box13_retirement_plan", default: 0
      t.integer "box13_statutory_employee", default: 0
      t.integer "box13_third_party_sick_pay", default: 0
      t.decimal "box3_social_security_wages", precision: 12, scale: 2
      t.decimal "box4_social_security_tax_withheld", precision: 12, scale: 2
      t.decimal "box5_medicare_wages_and_tip_amount", precision: 12, scale: 2
      t.decimal "box6_medicare_tax_withheld", precision: 12, scale: 2
      t.decimal "box7_social_security_tips_amount", precision: 12, scale: 2
      t.decimal "box8_allocated_tips", precision: 12, scale: 2
      t.string "box_d_control_number"
      t.datetime "completed_at"
      t.datetime "created_at", null: false
      t.string "creation_token"
      t.integer "employee", default: 0, null: false
      t.string "employee_city"
      t.string "employee_state"
      t.string "employee_street_address"
      t.string "employee_zip_code"
      t.string "employer_city"
      t.string "employer_ein"
      t.string "employer_name"
      t.string "employer_state"
      t.string "employer_street_address"
      t.string "employer_zip_code"
      t.decimal "federal_income_tax_withheld", precision: 12, scale: 2
      t.bigint "intake_id"
      t.datetime "updated_at", null: false
      t.decimal "wages_amount", precision: 12, scale: 2
      t.index ["creation_token"], name: "index_w2s_on_creation_token"
      t.index ["intake_id"], name: "index_w2s_on_intake_id"
    end

    safety_assured { add_foreign_key "w2s", "intakes" }
    set_pk_sequence!(
      'w2s',
      '(SELECT MAX(id) FROM archived_w2s_2022)'
    )
  end
end
