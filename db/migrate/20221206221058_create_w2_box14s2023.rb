class CreateW2Box14s2023 < ActiveRecord::Migration[7.0]
  def change
    create_table "w2_box14s" do |t|
      t.datetime "created_at", null: false
      t.decimal "other_amount", precision: 12, scale: 2
      t.string "other_description"
      t.datetime "updated_at", null: false
      t.bigint "w2_id", null: false
      t.index ["w2_id"], name: "index_w2_box14s_on_w2_id"
    end

    safety_assured { add_foreign_key "w2_box14s", "w2s" }
    set_pk_sequence!(
      'w2_box14s',
      '(SELECT MAX(id) FROM archived_w2s_2022)'
    )
  end
end
