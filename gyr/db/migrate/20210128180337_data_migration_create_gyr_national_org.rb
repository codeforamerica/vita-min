class DataMigrationCreateGyrNationalOrg < ActiveRecord::Migration[6.0]
  # Avoid using models in migrations by embedding referenced models
  # https://makandracards.com/makandra/15575-how-to-write-complex-migrations-in-rails
  class VitaPartner < ActiveRecord::Base
  end

  def up
    # Ensure this org exists
    VitaPartner.find_or_create_by!(name: "GYR National Organization")
  end

  def down
    # Harmless to leave this org in place
  end
end
