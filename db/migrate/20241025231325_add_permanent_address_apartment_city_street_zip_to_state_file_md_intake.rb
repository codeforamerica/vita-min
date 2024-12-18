class AddPermanentAddressApartmentCityStreetZipToStateFileMdIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md_intakes, :confirmed_permanent_address, :integer, default: 0, null: false
    add_column :state_file_md_intakes, :permanent_apartment, :string
    add_column :state_file_md_intakes, :permanent_city, :string
    add_column :state_file_md_intakes, :permanent_street, :string
    add_column :state_file_md_intakes, :permanent_zip, :string
  end
end
