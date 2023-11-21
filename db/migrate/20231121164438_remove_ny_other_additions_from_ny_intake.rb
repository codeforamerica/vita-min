class RemoveNyOtherAdditionsFromNyIntake < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :state_file_ny_intakes, :ny_other_additions, :integer }
  end
end
