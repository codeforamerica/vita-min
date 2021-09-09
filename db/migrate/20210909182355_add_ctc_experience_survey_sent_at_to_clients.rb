class AddCtcExperienceSurveySentAtToClients < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :ctc_experience_survey_sent_at, :datetime
    add_column :clients, :ctc_experience_survey_variant, :integer
  end
end
