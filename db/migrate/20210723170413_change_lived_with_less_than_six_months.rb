class ChangeLivedWithLessThanSixMonths < ActiveRecord::Migration[6.0]
  def change
    rename_column :dependents, :lived_with_less_than_six_months, :lived_with_more_than_six_months
  end
end
