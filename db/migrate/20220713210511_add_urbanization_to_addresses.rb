class AddUrbanizationToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :urbanization, :string
  end
end
