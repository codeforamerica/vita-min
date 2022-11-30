class Create2023BankAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_accounts do |t|
      t.text "account_number"
      t.integer "account_type"
      t.string "bank_name"
      t.datetime "created_at", null: false
      t.string "hashed_account_number"
      t.bigint "intake_id"
      t.string "routing_number"
      t.datetime "updated_at", null: false
      t.index ["hashed_account_number"], name: "index_bank_accounts_on_hashed_account_number"
      t.index ["intake_id"], name: "index_bank_accounts_on_intake_id"
      t.index ["routing_number"], name: "index_bank_accounts_on_routing_number"
    end
    safety_assured { add_foreign_key "bank_accounts", "intakes" }
    set_pk_sequence!(
      'bank_accounts',
      '(SELECT MAX(id) FROM archived_bank_accounts_2022)'
    )
  end
end
