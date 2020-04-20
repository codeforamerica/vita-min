class AddSpouseEmailAddressToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :spouse_email_address, :string
  end
end
