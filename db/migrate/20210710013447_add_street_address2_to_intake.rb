class AddStreetAddress2ToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :street_address2, :string
  end
end
