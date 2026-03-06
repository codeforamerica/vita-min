class CreateDocAssessmentFeedbacks < ActiveRecord::Migration[7.1]
  def change
    create_table :doc_assessment_feedbacks do |t|
      t.references :doc_assessment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.integer :feedback, null: false, default: 0
      t.text :feedback_notes

      t.timestamps
    end
  end
end
