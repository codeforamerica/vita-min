class ChangeDefaultPreferredInterviewLanguageOnIntakes < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:intakes, :preferred_interview_language, from: "English", to: nil)
  end
end
