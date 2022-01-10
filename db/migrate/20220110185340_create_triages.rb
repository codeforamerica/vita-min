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
      t.boolean :backtaxes_2018
      t.boolean :backtaxes_2019
      t.boolean :backtaxes_2020
      t.boolean :backtaxes_2021
      t.boolean :assistance_in_person
      t.boolean :assistance_chat
      t.boolean :assistance_phone_review_english
      t.boolean :assistance_phone_review_non_english
      t.boolean :assistance_none

      t.timestamps
    end
  end
end
