class AddCurrentStepToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :current_step, :string
  end
end
