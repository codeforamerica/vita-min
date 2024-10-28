class AddColumnsToStateFileW2 < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_w2s, :employer_name, :string
    add_column :state_file_w2s, :employee_name, :string
  end
end
