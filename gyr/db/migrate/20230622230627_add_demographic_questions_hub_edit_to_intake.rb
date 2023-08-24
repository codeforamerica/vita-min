class AddDemographicQuestionsHubEditToIntake < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :demographic_questions_hub_edit, :boolean, default: false
  end
end
