class AddIntakeTypeToW2 < ActiveRecord::Migration[7.1]
  def change
    add_column :w2s, :intake_type, :string
    add_column :w2s, :employee_ssn, :string
  end
end
