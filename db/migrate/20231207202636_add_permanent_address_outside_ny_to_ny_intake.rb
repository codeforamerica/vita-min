class AddPermanentAddressOutsideNyToNyIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_ny_intakes, :permanent_address_outside_ny, :integer, default: 0, null: false
  end
end
