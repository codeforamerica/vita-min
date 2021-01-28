class AddCompletedYesNoQuestionsAtToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :completed_yes_no_questions_at, :datetime, null: true
  end
end
