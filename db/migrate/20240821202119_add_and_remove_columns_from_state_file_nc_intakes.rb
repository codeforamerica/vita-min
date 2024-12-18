class AddAndRemoveColumnsFromStateFileNcIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :primary_middle_initial, :string
    add_column :state_file_nc_intakes, :primary_suffix, :string
    add_column :state_file_nc_intakes, :spouse_first_name, :string
    add_column :state_file_nc_intakes, :spouse_last_name, :string
    add_column :state_file_nc_intakes, :spouse_middle_initial, :string
    add_column :state_file_nc_intakes, :spouse_suffix, :string
    add_column :state_file_nc_intakes, :spouse_birth_date, :date

    safety_assured do
      remove_column :state_file_nc_intakes, :filing_status, :integer
    end
  end
end
