class AddColumnsToStateFileNyIntakes < ActiveRecord::Migration[7.0]
  def change
    add_column :state_file_ny_intakes, :tax_return_year, :integer
    add_column :state_file_ny_intakes, :tp_id, :string
    add_column :state_file_ny_intakes, :street_address, :string
    add_column :state_file_ny_intakes, :city, :string
    add_column :state_file_ny_intakes, :zip_code, :string
    add_column :state_file_ny_intakes, :ssn, :string
    add_column :state_file_ny_intakes, :birth_date, :date
    add_column :state_file_ny_intakes, :current_step, :string
  end
end
