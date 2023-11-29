class AddAndRemoveColumnsForStateFile1099Gs < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :state_file1099_gs, :payer_name_is_default, :integer }
    add_column :state_file1099_gs, :payer_street_address, :string
    add_column :state_file1099_gs, :payer_city, :string
    add_column :state_file1099_gs, :payer_zip, :string
    add_column :state_file1099_gs, :payer_tin, :string
    add_column :state_file1099_gs, :state_identification_number, :string
  end
end
