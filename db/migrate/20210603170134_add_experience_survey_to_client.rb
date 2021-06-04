class AddExperienceSurveyToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :experience_survey, :integer, default: 0, null: false
  end
end
