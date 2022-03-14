class RenameTaxYearAttributesOnDependent < ActiveRecord::Migration[6.1]
  def change
    rename_column :dependents, :born_in_2020, :residence_exception_born
    rename_column :dependents, :passed_away_2020, :residence_exception_passed_away
    rename_column :dependents, :placed_for_adoption, :residence_exception_adoption
  end
end
