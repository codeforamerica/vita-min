class UpdateIntakeToStoreXmlAndJsonFromDfApi < ActiveRecord::Migration[7.1]
  def up
    add_column :state_file_az_intakes, :raw_direct_file_intake_data, :jsonb
    add_column :state_file_nc_intakes, :raw_direct_file_intake_data, :jsonb
    add_column :state_file_nj_intakes, :raw_direct_file_intake_data, :jsonb
    add_column :state_file_ny_intakes, :raw_direct_file_intake_data, :jsonb

    add_column :state_file_az_intakes, :raw_direct_file_tax_return_data, :text
    add_column :state_file_nc_intakes, :raw_direct_file_tax_return_data, :text
    add_column :state_file_nj_intakes, :raw_direct_file_tax_return_data, :text
    add_column :state_file_ny_intakes, :raw_direct_file_tax_return_data, :text
  end
end
