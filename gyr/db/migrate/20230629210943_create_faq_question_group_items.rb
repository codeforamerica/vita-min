class CreateFaqQuestionGroupItems < ActiveRecord::Migration[7.0]
  def change
    create_table :faq_question_group_items do |t|
      t.string :group_name
      t.references :faq_item, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
