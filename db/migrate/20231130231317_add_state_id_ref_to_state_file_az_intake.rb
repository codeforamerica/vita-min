class AddStateIdRefToStateFileAzIntake < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :state_file_az_intakes, :primary_state_id, index: {algorithm: :concurrently}
    add_reference :state_file_az_intakes, :spouse_state_id, index: {algorithm: :concurrently}
  end
end
