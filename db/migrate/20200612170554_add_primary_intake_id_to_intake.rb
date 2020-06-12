class AddPrimaryIntakeIdToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :primary_intake_id, :integer
  end
end
