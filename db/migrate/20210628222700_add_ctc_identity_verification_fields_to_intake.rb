class AddCtcIdentityVerificationFieldsToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :navigator_name, :string
    add_column :intakes, :navigator_has_verified_client_identity, :boolean
  end
end
