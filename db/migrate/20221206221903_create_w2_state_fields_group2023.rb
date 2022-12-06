class CreateW2StateFieldsGroup2023 < ActiveRecord::Migration[7.0]
  def change
    create_table :w2_state_fields_groups do |t|
      t.string "box15_employer_state_id_number"
      t.string "box15_state"
      t.decimal "box16_state_wages", precision: 12, scale: 2
      t.decimal "box17_state_income_tax", precision: 12, scale: 2
      t.decimal "box18_local_wages", precision: 12, scale: 2
      t.decimal "box19_local_income_tax", precision: 12, scale: 2
      t.string "box20_locality_name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "w2_id", null: false
      t.index ["w2_id"], name: "index_w2_state_fields_groups_on_w2_id"
    end

    safety_assured { add_foreign_key "w2_state_fields_groups", "w2s" }
    set_pk_sequence!(
      'w2_state_fields_groups',
      '(SELECT MAX(id) FROM archived_w2s_2022)'
    )
  end
end
