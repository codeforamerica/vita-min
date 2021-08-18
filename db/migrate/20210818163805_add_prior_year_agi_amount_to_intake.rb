class AddPriorYearAgiAmountToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :primary_prior_year_agi_amount, :integer
    add_column :intakes, :spouse_prior_year_agi_amount, :integer
  end
end
