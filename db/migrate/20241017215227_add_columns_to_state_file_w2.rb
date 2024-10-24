class AddColumnsToStateFileW2 < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_w2s, :employer_name, :string, null: false
    add_column :state_file_w2s, :employee_name, :string, null: false
  end
end
