class AddSkipUspsValidationToAddresses < ActiveRecord::Migration[6.0]
  def change
    add_column :addresses, :skip_usps_validation, :boolean, default: false
  end
end
