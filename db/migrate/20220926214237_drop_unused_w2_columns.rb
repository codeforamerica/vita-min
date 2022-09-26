class DropUnusedW2Columns < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :w2s, :standard_or_non_standard_code
      remove_column :w2s, :employee_street_address2
      remove_column :w2s, :employer_street_address2
    end
  end
end
