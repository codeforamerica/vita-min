class AddSatisfactionFaceToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :satisfaction_face, :integer, null: false, default: 0 # unfilled
  end
end
