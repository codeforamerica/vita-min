class AddRecipientAddressColumnsToStateFile1099Rs < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file1099_rs, :recipient_address_line1, :string
    add_column :state_file1099_rs, :recipient_address_line2, :string
    add_column :state_file1099_rs, :recipient_city_name, :string
    add_column :state_file1099_rs, :recipient_state_code, :string
    add_column :state_file1099_rs, :recipient_zip, :string
  end
end
