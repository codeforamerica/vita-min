class Create2023Dependents < ActiveRecord::Migration[7.0]
  def change
    create_table :dependents do |t|
      t.integer "below_qualifying_relative_income_requirement", default: 0
      t.date "birth_date", null: false
      t.integer "cant_be_claimed_by_other", default: 0, null: false
      t.integer "claim_anyway", default: 0, null: false
      t.datetime "created_at", precision: nil, null: false
      t.string "creation_token"
      t.integer "disabled", default: 0, null: false
      t.integer "filed_joint_return", default: 0, null: false
      t.integer "filer_provided_over_half_support", default: 0
      t.string "first_name"
      t.integer "full_time_student", default: 0, null: false
      t.integer "has_ip_pin", default: 0, null: false
      t.bigint "intake_id", null: false
      t.text "ip_pin"
      t.string "last_name"
      t.integer "lived_with_more_than_six_months", default: 0, null: false
      t.integer "meets_misc_qualifying_relative_requirements", default: 0, null: false
      t.string "middle_initial"
      t.integer "months_in_home"
      t.integer "no_ssn_atin", default: 0, null: false
      t.integer "north_american_resident", default: 0, null: false
      t.integer "on_visa", default: 0, null: false
      t.integer "permanent_residence_with_client", default: 0, null: false
      t.integer "permanently_totally_disabled", default: 0, null: false
      t.integer "provided_over_half_own_support", default: 0, null: false
      t.string "relationship"
      t.integer "residence_exception_adoption", default: 0, null: false
      t.integer "residence_exception_born", default: 0, null: false
      t.integer "residence_exception_passed_away", default: 0, null: false
      t.integer "residence_lived_with_all_year", default: 0
      t.datetime "soft_deleted_at", precision: nil
      t.text "ssn"
      t.string "suffix"
      t.integer "tin_type"
      t.datetime "updated_at", precision: nil, null: false
      t.integer "was_married", default: 0, null: false
      t.integer "was_student", default: 0, null: false
      t.index ["creation_token"], name: "index_dependents_on_creation_token"
      t.index ["intake_id"], name: "index_dependents_on_intake_id"
    end
    safety_assured { add_foreign_key "dependents", "intakes" }
    set_pk_sequence!(
      'dependents',
      '(SELECT MAX(id) FROM archived_dependents_2022)'
    )
  end
end
