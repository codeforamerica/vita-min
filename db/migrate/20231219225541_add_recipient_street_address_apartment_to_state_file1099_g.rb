class AddRecipientStreetAddressApartmentToStateFile1099G < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file1099_gs, :recipient_street_address_apartment, :string, null: true
  end
end
