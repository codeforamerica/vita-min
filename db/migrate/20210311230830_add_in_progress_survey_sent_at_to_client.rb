class AddInProgressSurveySentAtToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :in_progress_survey_sent_at, :datetime
    add_index :clients, :in_progress_survey_sent_at
  end
end
