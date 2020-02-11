class AddInterviewTimingPreferenceToIntakes < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :interview_timing_preference, :string
  end
end
