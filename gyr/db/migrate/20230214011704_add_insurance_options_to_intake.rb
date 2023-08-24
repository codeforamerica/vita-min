class AddInsuranceOptionsToIntake < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :bought_employer_health_insurance, :integer, default: 0, null: false
    add_column :intakes, :had_medicaid_medicare, :integer, default: 0, null: false
  end
end