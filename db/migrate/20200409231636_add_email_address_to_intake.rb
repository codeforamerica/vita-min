class AddEmailAddressToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :email_address, :string
  end
end
