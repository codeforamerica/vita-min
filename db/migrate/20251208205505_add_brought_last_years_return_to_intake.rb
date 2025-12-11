class AddBroughtLastYearsReturnToIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :brought_last_years_return, :integer, default: 0, null: false
  end
end
