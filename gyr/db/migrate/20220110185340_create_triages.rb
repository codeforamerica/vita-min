class CreateTriages < ActiveRecord::Migration[6.1]
  def change
    create_table :triages do |t|
      t.string :source
      t.string :referrer
      t.string :locale
      t.string :visitor_id
      t.integer :income_level
      t.integer :id_type
      t.integer :doc_type
      t.integer :filed_2018, default: 0, null: false
      t.integer :filed_2019, default: 0, null: false
      t.integer :filed_2020, default: 0, null: false
      t.integer :filed_2021, default: 0, null: false
      t.integer :assistance_in_person, default: 0, null: false
      t.integer :assistance_chat, default: 0, null: false
      t.integer :assistance_phone_review_english, default: 0, null: false
      t.integer :assistance_phone_review_non_english, default: 0, null: false
      t.integer :income_type_rent, default: 0, null: false
      t.integer :income_type_farm, default: 0, null: false

      t.timestamps
    end
  end
end
