class AddSuffixToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :primary_suffix, :string
    add_column :state_file_ny_intakes, :primary_suffix, :string
    add_column :state_file_az_intakes, :spouse_suffix, :string
    add_column :state_file_ny_intakes, :spouse_suffix, :string
  end
end