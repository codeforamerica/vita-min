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
      t.integer :backtaxes_2018, default: 0, null: false
      t.integer :backtaxes_2019, default: 0, null: false
      t.integer :backtaxes_2020, default: 0, null: false
      t.integer :backtaxes_2021, default: 0, null: false
      t.integer :assistance_in_person, default: 0, null: false
      t.integer :assistance_chat, default: 0, null: false
      t.integer :assistance_phone_review_english, default: 0, null: false
      t.integer :assistance_phone_review_non_english, default: 0, null: false

      t.timestamps
    end
  end
end
