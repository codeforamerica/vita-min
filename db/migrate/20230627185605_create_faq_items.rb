class CreateFaqItems < ActiveRecord::Migration[7.0]
  def change
    create_table :faq_items do |t|
      t.integer :position
      t.text :question_en
      t.text :question_es
      t.text :answer_en
      t.text :answer_es
      t.references :faq_category, null: false, foreign_key: true
      t.string :slug

      t.timestamps
    end
  end
end
