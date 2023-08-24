class CreateFaqSurveys < ActiveRecord::Migration[6.1]
  def change
    create_table :faq_surveys do |t|
      t.integer :answer, default: 0, null: false
      t.string :visitor_id, null: false
      t.string :question_key, null: false

      t.timestamps
    end
  end
end
