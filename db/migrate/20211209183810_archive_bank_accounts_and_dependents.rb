class ArchiveBankAccountsAndDependents < ActiveRecord::Migration[6.1]
  def change
    rename_table :bank_accounts, :archived_bank_accounts_2021
    rename_column :archived_bank_accounts_2021, :intake_id, :archived_intakes_2021_id
    add_foreign_key "archived_bank_accounts_2021", "archived_intakes_2021"

    create_table "bank_accounts", force: :cascade do |t|
      t.integer "account_type"
      t.datetime "created_at", precision: 6, null: false
      t.string "encrypted_account_number"
      t.string "encrypted_account_number_iv"
      t.string "encrypted_bank_name"
      t.string "encrypted_bank_name_iv"
      t.string "encrypted_routing_number"
      t.string "encrypted_routing_number_iv"
      t.string "hashed_account_number"
      t.string "hashed_routing_number"
      t.bigint "intake_id"
      t.datetime "updated_at", precision: 6, null: false
      t.index ["hashed_account_number"], name: "index_bank_accounts_on_hashed_account_number"
      t.index ["hashed_routing_number"], name: "index_bank_accounts_on_hashed_routing_number"
      t.index ["intake_id"], name: "index_bank_accounts_on_intake_id"
    end
    add_foreign_key "bank_accounts", "intakes"
    set_pk_sequence!(
      'bank_accounts',
      '(SELECT MAX(id) FROM archived_bank_accounts_2021)'
    )

    rename_table :dependents, :archived_dependents_2021
    rename_column :archived_dependents_2021, :intake_id, :archived_intakes_2021_id
    add_foreign_key "archived_dependents_2021", "archived_intakes_2021"

    create_table "dependents", force: :cascade do |t|
      t.date "birth_date", null: false
      t.integer "born_in_2020", default: 0, null: false
      t.integer "cant_be_claimed_by_other", default: 0, null: false
      t.integer "claim_anyway", default: 0, null: false
      t.datetime "created_at", null: false
      t.string "creation_token"
      t.integer "disabled", default: 0, null: false
      t.string "encrypted_ip_pin"
      t.string "encrypted_ip_pin_iv"
      t.string "encrypted_ssn"
      t.string "encrypted_ssn_iv"
      t.integer "filed_joint_return", default: 0, null: false
      t.string "first_name"
      t.integer "full_time_student", default: 0, null: false
      t.integer "has_ip_pin", default: 0, null: false
      t.bigint "intake_id", null: false
      t.string "last_name"
      t.integer "lived_with_more_than_six_months", default: 0, null: false
      t.integer "meets_misc_qualifying_relative_requirements", default: 0, null: false
      t.string "middle_initial"
      t.integer "months_in_home"
      t.integer "no_ssn_atin", default: 0, null: false
      t.integer "north_american_resident", default: 0, null: false
      t.integer "on_visa", default: 0, null: false
      t.integer "passed_away_2020", default: 0, null: false
      t.integer "permanent_residence_with_client", default: 0, null: false
      t.integer "permanently_totally_disabled", default: 0, null: false
      t.integer "placed_for_adoption", default: 0, null: false
      t.integer "provided_over_half_own_support", default: 0, null: false
      t.string "relationship"
      t.datetime "soft_deleted_at"
      t.string "suffix"
      t.integer "tin_type"
      t.datetime "updated_at", null: false
      t.integer "was_married", default: 0, null: false
      t.integer "was_student", default: 0, null: false
      t.index ["creation_token"], name: "index_dependents_on_creation_token"
      t.index ["intake_id"], name: "index_dependents_on_intake_id"
    end
    add_foreign_key "dependents", "intakes"
    set_pk_sequence!(
      'dependents',
      '(SELECT MAX(id) FROM archived_dependents_2021)'
    )
  end
end
