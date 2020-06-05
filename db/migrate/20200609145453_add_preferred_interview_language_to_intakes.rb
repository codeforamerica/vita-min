class AddPreferredInterviewLanguageToIntakes < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :preferred_interview_language, :string, default: "English"
  end
end
