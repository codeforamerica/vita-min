class DataMigrationCreateGyrNationalOrg < ActiveRecord::Migration[6.0]
  def up
    # Ensure this org exists
    VitaPartner.find_or_create_by!(name: "GYR National Organization")
  end

  def down
    # Harmless to leave this org in place
  end
end
