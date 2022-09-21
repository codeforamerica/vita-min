class AddEmployeeToW2 < ActiveRecord::Migration[7.0]
  def change
    add_column :w2s, :employee, :integer, default: 0, null: false
    safety_assured do #skipping the ignored_columns step because this is still all behind a feature flag
      remove_column :w2s, :legal_first_name
      remove_column :w2s, :legal_last_name
      remove_column :w2s, :legal_middle_initial
      remove_column :w2s, :suffix
      remove_column :w2s, :employee_ssn
    end
  end
end
