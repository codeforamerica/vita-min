class MakeBirthDateNonNullOnDependents < ActiveRecord::Migration[6.0]
  def change
    change_column_null :dependents, :birth_date, false
  end
end
