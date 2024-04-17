class AddEmailAddressIndexToIntake < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :state_file_az_intakes, :email_address, algorithm: :concurrently
    add_index :state_file_ny_intakes, :email_address, algorithm: :concurrently
  end

end
