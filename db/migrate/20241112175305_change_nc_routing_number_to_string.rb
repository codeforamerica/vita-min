class ChangeNcRoutingNumberToString < ActiveRecord::Migration[7.1]
  def change
    # This column cannot be written to as it is, due to it giving an encryption error, should always be empty
    safety_assured { change_column :state_file_nc_intakes, :routing_number, :string }
  end
end
