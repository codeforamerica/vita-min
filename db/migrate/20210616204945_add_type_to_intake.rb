class AddTypeToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :type, :string, default: "Intake::GyrIntake"
    change_column_default(:intakes, :type, from: "Intake::GyrIntake", to: nil)
  end
end
