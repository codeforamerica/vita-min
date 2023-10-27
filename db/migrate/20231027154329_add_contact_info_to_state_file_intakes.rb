class AddContactInfoToStateFileIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_ny_intakes, :email_address, :citext
    add_column :state_file_ny_intakes, :phone_number, :string
    
    add_column :state_file_az_intakes, :email_address, :citext
    add_column :state_file_az_intakes, :phone_number, :string
  end
end
