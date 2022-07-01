class AddUspsAddressVerifiedAtToIntakes < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :usps_address_verified_at, :datetime
  end
end
