class AddFakeAddressToStateFileArchivedIntakeRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_archived_intake_requests, :fake_address_1, :string
    add_column :state_file_archived_intake_requests, :fake_address_2, :string
  end
end
