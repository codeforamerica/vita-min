class AddCanonicalEmailAddressToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :canonical_email_address, :string
  end
end
