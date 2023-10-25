class AddConfirmedPermanentAddressToStateFileNyIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_ny_intakes, :confirmed_permanent_address, :integer, default: 0, null: false
  end
end
