class AddCompletionSurveySentAtToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :completion_survey_sent_at, :datetime, null: true
  end
end
