class RemoveNy414RetirementFromStateFileNyIntake < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :state_file_ny_intakes, :ny_414h_retirement, :integer }
  end
end
