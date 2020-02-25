class AddIncomeOverLimitToIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :income_over_limit, :integer, default: 0, null: false
  end
end
